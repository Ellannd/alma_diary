import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:alma_diary/state/challenges/challenge_provider.dart";
import "package:alma_diary/features/challenges/challenge_repository.dart";
import "package:alma_diary/features/challenges/engine/challenges_engine_v2.dart";
import "package:alma_diary/state/notifications/notifications_controller.dart";
import "package:alma_diary/state/challenges/challenge_state.dart";
import "package:alma_diary/state/notifications/notifications_provider.dart";

class ChallengeController extends Notifier<ChallengeState> {
  late final ChallengeRepository _repository;
  late final ChallengesEngine _engine;
  late final NotificationController _notification;

  @override
  ChallengeState build() {
    _repository = ref.read(challengeRepositoryProvider);
    _engine = ref.read(challengesEngineProvider);
    _notification = ref.read(notificationControllerProvider.notifier);

    return ChallengeState.initial();
  }

  // =========================
  // INIT USER
  // =========================
  void setUserId(String userId) {
    state = state.copyWith(userId: userId);
  }

  // =========================
  // LOAD
  // =========================
  Future<void> loadChallenges() async {
    final userId = state.userId;

    if (userId == null) {
      state = state.copyWith(error: 'Usuario no autenticado');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final challenges = await _repository.getChallenges();
      final userChallenges =
          await _repository.getUserChallenges(userId);

      final challengeMap = {
        for (var c in challenges) c.id: c,
      };

      final progressMap = {
        for (var uc in userChallenges) uc.challengeId: uc.progress,
      };

      final statusMap = {
        for (var uc in userChallenges) uc.challengeId: uc.status,
      };

      state = state.copyWith(
        challenges: challenges,
        userChallenges: userChallenges,
        challengeMap: challengeMap,
        progressByChallenge: progressMap,
        statusByChallenge: statusMap,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar desafíos',
      );
    }
  }

  // =========================
  // START
  // =========================
  Future<bool> startChallenge(String challengeId) async {
    final userId = state.userId;
    if (userId == null) return false;

    final challenge = state.challengeMap[challengeId];
    if (challenge == null) return false;

    final (isValid, errorMessage) = _engine.validateStart(
      challenge: challenge,
      existingUserChallenges: state.userChallenges,
    );

    if (!isValid) {
      state = state.copyWith(error: errorMessage);
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repository.insertUserChallenge(
        userId: userId,
        challenge: challenge,
      );

      final newUC = UserChallenge(
        id: '',
        challengeId: challengeId,
        status: 'active',
        progress: 0,
        startedAt: DateTime.now(),
      );

      final updatedList = [...state.userChallenges, newUC];

      state = state.copyWith(
        userChallenges: updatedList,
        progressByChallenge: {
          ...state.progressByChallenge,
          challengeId: 0,
        },
        statusByChallenge: {
          ...state.statusByChallenge,
          challengeId: 'active',
        },
        isLoading: false,
      );

      await _notification.handleChallengeEvent(
        userId,
        challenge.title,
        eventType: 'started',
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al iniciar desafío',
      );
      return false;
    }
  }

  // =========================
  // UPDATE PROGRESS
  // =========================
  Future<bool> updateProgress(
      String challengeId, int newProgress) async {
    final userId = state.userId;
    if (userId == null) return false;

    final challenge = state.challengeMap[challengeId];
    if (challenge == null) return false;

    final currentProgress =
        state.progressByChallenge[challengeId] ?? 0;

    final calculated = _engine.calculateProgress(
      currentProgress: currentProgress,
      increment: newProgress - currentProgress,
    );

    final isCompleted = _engine.isProgressCompleted(calculated);
    final newStatus = _engine.determineStatus(calculated);

    state = state.copyWith(isLoading: true);

    try {
      await _repository.updateUserChallenge(
        userId: userId,
        challenge: challenge,
        progress: calculated,
        isCompleted: isCompleted,
      );

      final updatedUC = UserChallenge(
        id: '',
        challengeId: challengeId,
        status: newStatus,
        progress: calculated,
        startedAt: DateTime.now(),
        completedAt: isCompleted ? DateTime.now() : null,
      );

      state = state.copyWith(
        userChallenges: [
          ...state.userChallenges.where(
              (uc) => uc.challengeId != challengeId),
          updatedUC
        ],
        progressByChallenge: {
          ...state.progressByChallenge,
          challengeId: calculated,
        },
        statusByChallenge: {
          ...state.statusByChallenge,
          challengeId: newStatus,
        },
        isLoading: false,
      );

      if (isCompleted) {
        final reward = _engine.calculateReward(
          challenge: challenge,
          finalProgress: calculated,
          durationDays: 1,
        );

        await _notification.handleChallengeEvent(
          userId,
          challenge.title,
          eventType: 'completed',
          points: reward,
        );
      }

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al actualizar progreso',
      );
      return false;
    }
  }

  // =========================
  // RESET
  // =========================
  void reset() {
    state = ChallengeState.initial();
  }
}