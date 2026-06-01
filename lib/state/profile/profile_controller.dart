import 'dart:async';

import 'package:alma_diary/core/analytics/auth_analytics.dart';

import 'package:alma_diary/core/crypto/crypto_provider.dart';
import 'package:alma_diary/state/notifications/notifications_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:alma_diary/features/profile/domain/profile.dart';
import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/features/profile/data/profile_repository.dart';

// =============================================================================
// PROVIDERS
// =============================================================================

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  throw UnimplementedError('Provide ProfileRepository in main');
});

// Modifica tu provider de usuario para que sea reactivo al stream
final currentUserProvider = Provider<User?>((ref) {
  // Vigilamos el flujo del stream. Cada vez que cambie la auth, 
  // este provider emitirá el nuevo valor síncronamente.
  final authState = ref.watch(authChangesProvider).value;
  return authState?.session?.user ?? Supabase.instance.client.auth.currentUser;
});

// Stream reactivo — SOLO para invalidar otros providers cuando cambia auth.
// No usar .future de este provider, solo ref.listen().
final authChangesProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, Profile?>(
  ProfileController.new,
);

// =============================================================================
// CONTROLLER
// =============================================================================

class ProfileController extends AsyncNotifier<Profile?> {
  ProfileRepository? _repo;
  bool _postLoginFired = false;

  @override
  Future<Profile?> build() async {
    _repo = ref.read(profileRepositoryProvider);

    await ref.watch(cryptoSessionProvider.future);

    final user = ref.watch(currentUserProvider);
    //Analytics user identification
    if (user == null) {
       await AuthAnalytics.onAuthSignOut();
      return null;}

    await AuthAnalytics.onAuthSuccess(user.id);

    final profile = await _fetchProfile(user.id);

    // Disparar post-login después de cargar el perfil
    if (profile != null && profile.isOnboardingComplete && !_postLoginFired) {
      _postLoginFired = true;
      Future.microtask(() =>
        ref.read(notificationControllerProvider.notifier)
          .handlePostLogin(user.id)
      );
    }

    return profile;
  }

  Future<Profile?> _fetchProfile(String userId) async {
    await _repo?.ensureProfileExists(userId);

    Profile? profile;
    for (int i = 0; i < 3; i++) {
      profile = await _repo?.getUserProfile(userId);
      if (profile != null) break;
      await Future.delayed(const Duration(milliseconds: 300));
    }

    LogService.instance.info(
      'profile.load_success',
      context: {
        'user_id': userId,
        'onboarding': profile?.isOnboardingComplete,
      },
    );

    return profile;
  }

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = await AsyncValue.guard(() async {
      await _repo?.updateProfile(data);
      final updated = await _repo?.getUserProfile(user.id);
      LogService.instance.info('profile.update_success',
          context: {'user_id': user.id});
      return updated;
    });

    if (state.hasError) {
      LogService.instance.error('profile.update_failed',
          error: state.error, stackTrace: state.stackTrace);
    }
  }

  Future<void> completeOnboarding({
    required String emotionalState,
    required String painPoint,
    required String hopefulGoal,
    String? name,
    String? mainChallenge,
    String? preferredLanguage,
    int? stressLevel,
    String? sleepQuality,
    String? archetype,
  List<String>? painNodes,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = await AsyncValue.guard(() async {
      await _repo?.completeOnboarding(
        emotionalState: emotionalState,
        painPoint: painPoint,
        hopefulGoal: hopefulGoal,
        mainChallenge: mainChallenge,
        preferredLanguage: preferredLanguage,
        stressLevel: stressLevel,
        sleepQuality: sleepQuality,
        archetype: archetype,
        painNodes: painNodes,
      );

      if (name != null && name.isNotEmpty) {
        await _repo?.updateProfile({'full_name': name});
      }

      final updated = await _repo?.getUserProfile(user.id);
      LogService.instance.info('profile.onboarding_success',
          context: {'user_id': user.id});
      return updated;
    });

    if (state.hasError) {
      LogService.instance.error('profile.onboarding_failed',
          error: state.error, stackTrace: state.stackTrace);
    }
  }

  bool get isAuthenticated => ref.read(currentUserProvider) != null;
  bool get isOnboardingComplete => state.value?.isOnboardingComplete ?? false;

  String get displayName {
    final user = ref.read(currentUserProvider);
    final fullName = state.value?.displayName ??
        user?.userMetadata?['name'] as String? ??
        user?.userMetadata?['full_name'] as String? ??
        user?.email;
    if (fullName == null || fullName.isEmpty) return 'Usuario';
    return fullName.split(RegExp(r'\s+')).first;
  }

  String get email {
    final user = ref.read(currentUserProvider);
    return state.value?.email ?? user?.email ?? '';
  }

  String? get avatarUrl {
    final user = ref.read(currentUserProvider);
    return state.value?.avatarUrl ??
        user?.userMetadata?['avatar_url'] as String?;
  }

  
}