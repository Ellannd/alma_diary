import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alma_diary/services/supabase_service.dart';
import 'package:alma_diary/core/logging/log_service.dart';

import 'package:alma_diary/features/profile/domain/profile.dart';

class ProfileRepository {
  final SupabaseClient _client = SupabaseService.instance.client;

  User? get currentUser => _client.auth.currentUser;

  // =========================
  // ENSURE PROFILE
  // =========================
  Future<void> ensureProfileExists(String userId) async {
    try {
      final existing = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

if (existing == null) {
         await _client.from('profiles').insert({
           'id': userId,
           'email': currentUser?.email,
           'is_onboarding_complete': false,
           'created_at': DateTime.now().toIso8601String(),
         });

        LogService.instance.info(
          'profile.created',
          context: {'user_id': userId},
        );
      }
    } catch (e, st) {
      LogService.instance.error(
        'profile.ensure_failed',
        error: e,
        stackTrace: st,
        context: {'user_id': userId},
      );
      rethrow;
    }
  }

  // =========================
  // GET
  // =========================
  Future<Profile?> getUserProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return null;

      return Profile.fromMap(data);
    } catch (e, st) {
      LogService.instance.error(
        'profile.get_failed',
        error: e,
        stackTrace: st,
        context: {'user_id': userId},
      );
      return null;
    }
  }
  // =========================
  // UPDATE
  // =========================
  Future<void> updateProfile(Map<String, dynamic> data) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('No auth user');

    try {
      await _client
          .from('profiles')
          .update({
            ...data,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

      LogService.instance.info(
        'profile.updated',
        context: {'user_id': userId},
      );
    } catch (e, st) {
      LogService.instance.error(
        'profile.update_failed',
        error: e,
        stackTrace: st,
        context: {'user_id': userId},
      );
      rethrow;
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
    String? sleepQuality, String? name,
  }) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('No auth user');

    try {
      await _client.from('profiles').update({
        'emotional_state': emotionalState,
        'pain_point': painPoint,
        'hopeful_goal': hopefulGoal,
        'main_challenge': mainChallenge,
        'preferred_language': preferredLanguage,
        'stress_level': stressLevel,
        'sleep_quality': sleepQuality,
        'is_onboarding_complete': true,
        'updated_at': DateTime.now().toIso8601String(),
        "full_name": name,
      }).eq('id', userId);

      LogService.instance.info(
        'profile.onboarding_completed',
        context: {'user_id': userId},
      );
    } catch (e, st) {
      LogService.instance.error(
        'profile.onboarding_failed',
        error: e,
        stackTrace: st,
        context: {'user_id': userId},
      );
      rethrow;
    }
  }

  String getFirstName(String? fullName) {
    if (fullName == null) return 'Usuario';

    final cleaned = fullName.trim();

    if (cleaned.isEmpty) return 'Usuario';

    return cleaned.split(RegExp(r'\s+')).first;
  }

}