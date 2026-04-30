import "package:supabase_flutter/supabase_flutter.dart";
import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/features/profile/data/profile_repository.dart';


class ProfileController {
  final ProfileRepository _repo;

  ProfileController(this._repo);

  Map<String, dynamic>? _profile;

  User? _user;

    void setContext({
    required Map<String, dynamic>? profile,
    required User? user,
  }) {
    _profile = profile;
    _user = user;
  }

  // =========================
  // LOAD PROFILE (FLOW COMPLETO)
  // =========================
  Future<Map<String, dynamic>?> loadProfile(String userId) async {
    try {
      LogService.instance.info(
        'profile.load_start',
        context: {'user_id': userId},
      );

      // 1. asegurar existencia
      await _repo.ensureProfileExists(userId);

      // 2. cargar perfil
      final profile = await _repo.getUserProfile(userId);

      LogService.instance.info(
        'profile.load_success',
        context: {
          'user_id': userId,
          'onboarding': profile?['is_onboarding_complete'],
        },
      );

      return profile;
    } catch (e, st) {
      LogService.instance.error(
        'profile.load_failed',
        error: e,
        stackTrace: st,
        context: {'user_id': userId},
      );
      rethrow;
    }
  }

  // =========================
  // UPDATE PROFILE
  // =========================
  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _repo.updateProfile(data);
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
    await _repo.completeOnboarding(
      emotionalState: emotionalState,
      painPoint: painPoint,
      hopefulGoal: hopefulGoal,
      mainChallenge: mainChallenge,
      preferredLanguage: preferredLanguage,
      stressLevel: stressLevel,
      sleepQuality: sleepQuality,
    );
  }


String get displayName {
    return _profile?['full_name']
        ?? _user?.userMetadata?['name']
        ?? _user?.email
        ?? 'Usuario';
  }

  /// Returns the first name by trimming at the first space
  String get firstName {
    final name = displayName;
    final spaceIndex = name.indexOf(' ');
    if (spaceIndex == -1) return name;
    return name.substring(0, spaceIndex);
  }

}
