import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import "package:alma_diary/features/profile/domain/profile.dart";
import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/features/profile/data/profile_repository.dart';
import "package:alma_diary/state/profile/profile_state.dart";

/// =========================
/// PROVIDERS
/// =========================
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  throw UnimplementedError('Provide ProfileRepository in main');
});

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(
  ProfileController.new,
);


/// =========================
/// CONTROLLER (MODERNO)
/// =========================
class ProfileController extends Notifier<ProfileState> {
  late final ProfileRepository _repo;

  @override
  ProfileState build() {
    _repo = ref.read(profileRepositoryProvider);
    return const ProfileState();
  }

  // =========================
  // INIT
  // =========================
  Future<void> init(String userId, User? user) async {
    state = state.copyWith(isLoading: true, user: user);

    try {
      final profile = await _repo.getUserProfile(userId);

      state = state.copyWith(
        profile: profile,
        isLoading: false,
        initialized: true,
      );

      LogService.instance.info(
        'profile.init_success',
        context: {'user_id': userId},
      );
    } catch (e, st) {
      LogService.instance.error(
        'profile.init_failed',
        error: e,
        stackTrace: st,
        context: {'user_id': userId},
      );

      state = state.copyWith(
        isLoading: false,
        error: 'Error al inicializar perfil',
      );
    }
  }

Future<void> loadProfile(String userId) async {
  state = state.copyWith(isLoading: true);

  try {
    await _repo.ensureProfileExists(userId);
    final profile = await _repo.getUserProfile(userId);

    state = state.copyWith(
      profile: profile,
      isLoading: false,
      initialized: true,  
    );

    LogService.instance.info(
      'profile.load_success',
      context: {
        'user_id': userId,
        'onboarding': profile?.isOnboardingComplete,
      },
    );
  } catch (e, st) {
    LogService.instance.error(
      'profile.load_failed',
      error: e,
      stackTrace: st,
      context: {'user_id': userId},
    );

    state = state.copyWith(
      isLoading: false,
      initialized: true,  
      error: 'Error al cargar perfil',
    );
  }
}

  // =========================
  // UPDATE PROFILE
  // =========================
  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);

    try {
      await _repo.updateProfile(data);

      final userId = state.user?.id;
      if (userId != null) {
        final updated = await _repo.getUserProfile(userId);
        state = state.copyWith(profile: updated);
      }

      state = state.copyWith(isLoading: false);
    } catch (e, st) {
      LogService.instance.error(
        'profile.update_failed',
        error: e,
        stackTrace: st,
      );

      state = state.copyWith(
        isLoading: false,
        error: 'Error al actualizar perfil',
      );
    }
  }

  
  // =========================
  // ONBOARDING
  // =========================
  Future<void> completeOnboarding({
    required String emotionalState,
    required String painPoint,
    required String hopefulGoal,
    String? mainChallenge,
    String? preferredLanguage,
    int? stressLevel,
    String? sleepQuality,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      await _repo.completeOnboarding(
        emotionalState: emotionalState,
        painPoint: painPoint,
        hopefulGoal: hopefulGoal,
        mainChallenge: mainChallenge,
        preferredLanguage: preferredLanguage,
        stressLevel: stressLevel,
        sleepQuality: sleepQuality,
      );

      final userId = state.user?.id;
      if (userId != null) {
        final updated = await _repo.getUserProfile(userId);
        state = state.copyWith(profile: updated);
      }

      state = state.copyWith(isLoading: false);
    } catch (e, st) {
      LogService.instance.error(
        'profile.onboarding_failed',
        error: e,
        stackTrace: st,
      );

      state = state.copyWith(
        isLoading: false,
        error: 'Error en onboarding',
      );
    }
  }

  // =========================
  // DERIVED GETTERS
  // =========================
  bool get isAuthenticated => state.user != null;

  bool get isReady => state.initialized;

  String get displayName {
    final fullName = state.profile?.displayName ??
        state.user?.userMetadata?['name'] ??
        state.user?.email;

    if (fullName == null || fullName.isEmpty) return 'Usuario';
    return fullName.split(RegExp(r'\s+')).first;
  }

  String get email =>
    state.profile?.email ??
    state.user?.email ??
    '';

  String? get avatarUrl =>
    state.profile?.avatarUrl ??
    state.user?.userMetadata?['avatar_url'];

      bool get isOnboardingComplete {
    final profile = state.profile;
    if (profile == null) return false;

    return state.profile?.isOnboardingComplete ?? false;
  }
}