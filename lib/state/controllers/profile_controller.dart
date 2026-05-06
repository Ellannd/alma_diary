import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/features/profile/data/profile_repository.dart';

/// =========================
/// STATE
/// =========================
class ProfileState {
  final Map<String, dynamic>? profile;
  final User? user;
  final bool loading;
  final bool initialized;
  final String? error;

  const ProfileState({
    this.profile,
    this.user,
    this.loading = false,
    this.initialized = false,
    this.error,
  });

  ProfileState copyWith({
    Map<String, dynamic>? profile,
    User? user,
    bool? loading,
    bool? initialized,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      user: user ?? this.user,
      loading: loading ?? this.loading,
      initialized: initialized ?? this.initialized,
      error: error,
    );
  }
}

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
    state = state.copyWith(loading: true, user: user);

    try {
      final profile = await _repo.getUserProfile(userId);

      state = state.copyWith(
        profile: profile,
        loading: false,
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
        loading: false,
        error: 'Error al inicializar perfil',
      );
    }
  }

  // =========================
  // LOAD PROFILE
  // =========================
  Future<void> loadProfile(String userId) async {
    state = state.copyWith(loading: true);

    try {
      await _repo.ensureProfileExists(userId);

      final profile = await _repo.getUserProfile(userId);

      state = state.copyWith(
        profile: profile,
        loading: false,
      );

      LogService.instance.info(
        'profile.load_success',
        context: {
          'user_id': userId,
          'onboarding': profile?['is_onboarding_complete'],
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
        loading: false,
        error: 'Error al cargar perfil',
      );
    }
  }

  // =========================
  // UPDATE PROFILE
  // =========================
  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(loading: true);

    try {
      await _repo.updateProfile(data);

      final userId = state.user?.id;
      if (userId != null) {
        final updated = await _repo.getUserProfile(userId);
        state = state.copyWith(profile: updated);
      }

      state = state.copyWith(loading: false);
    } catch (e, st) {
      LogService.instance.error(
        'profile.update_failed',
        error: e,
        stackTrace: st,
      );

      state = state.copyWith(
        loading: false,
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
    state = state.copyWith(loading: true);

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

      state = state.copyWith(loading: false);
    } catch (e, st) {
      LogService.instance.error(
        'profile.onboarding_failed',
        error: e,
        stackTrace: st,
      );

      state = state.copyWith(
        loading: false,
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
    final fullName = state.profile?['full_name'] ??
        state.user?.userMetadata?['name'] ??
        state.user?.email;

    if (fullName == null || fullName.isEmpty) return 'Usuario';
    return fullName.split(RegExp(r'\s+')).first;
  }

  String get firstName {
    final name = displayName;
    final spaceIndex = name.indexOf(' ');
    if (spaceIndex == -1) return name;
    return name.substring(0, spaceIndex);
  }

  String get email => state.user?.email ?? '';

  String? get avatarUrl =>
      state.profile?['avatar_url'] ??
      state.user?.userMetadata?['avatar_url'];
}