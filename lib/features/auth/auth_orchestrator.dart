import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alma_diary/features/profile/controller/profile_controller.dart';
import 'package:alma_diary/features/notifications/controller/notifications_controller.dart';
import 'package:alma_diary/core/logging/log_service.dart';

class AuthOrchestrator {
  final ProfileController _profileController;
  final NotificationController _notificationController;

  AuthOrchestrator(
    this._profileController,
    this._notificationController,
  );

  // =====================================================
  // MAIN FLOW: LOAD USER SESSION
  // =====================================================
  Future<Map<String, dynamic>?> loadUserSession({
    required String userId,
  }) async {
    try {
      LogService.instance.info(
        'auth.orchestrator.start',
        context: {'user_id': userId},
      );

      // 1. PROFILE
      final profile = await _profileController.loadProfile(userId);

      // 2. SIDE EFFECTS (NO UI LOGIC HERE)
      await _notificationController.handlePostLogin(userId);

      LogService.instance.info(
        'auth.orchestrator.success',
        context: {
          'user_id': userId,
          'onboarding': profile?['is_onboarding_complete'],
        },
      );

      return profile;
    } catch (e, st) {
      LogService.instance.error(
        'auth.orchestrator.failed',
        error: e,
        stackTrace: st,
        context: {'user_id': userId},
      );

      rethrow;
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // =====================================================
  // OPTIONAL: ONBOARDING COMPLETED FLOW
  // =====================================================
  Future<void> handleOnboardingCompleted(String userId) async {
    try {
      await _notificationController.handleOnboardingCompleted(userId);
    } catch (e, st) {
      LogService.instance.error(
        'auth.orchestrator.onboarding_failed',
        error: e,
        stackTrace: st,
      );
    }
  }
}