import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alma_diary/ai/engines/notifications_engine.dart';
import 'package:alma_diary/core/logging/log_service.dart';

class NotificationController {
  final AlmaNotificationEngine _engine;

  NotificationController(SupabaseClient client)
      : _engine = AlmaNotificationEngine(client);

  // =====================================================
  // 1. POST LOGIN FLOW (AUTH CONTEXT)
  // =====================================================
  Future<void> handlePostLogin(String userId) async {
    try {
      LogService.instance.info(
        'notifications.post_login.start',
        context: {'user_id': userId},
      );

      await Future.wait([
        _engine.generateDailyQuote(userId),
        _engine.trackLoginEvent(userId),
      ]);

      LogService.instance.info(
        'notifications.post_login.success',
      );
    } catch (e, st) {
      LogService.instance.error(
        'notifications.post_login.failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  // =====================================================
  // 2. ONBOARDING COMPLETED FLOW
  // =====================================================
  Future<void> handleOnboardingCompleted(String userId) async {
    try {
      await Future.wait([
        _engine.notifyInsight(
          userId: userId,
          title: 'Bienvenido a Alma',
          message: 'Tu viaje ha comenzado',
        ),
        _engine.trackOnboardingEvent(userId),
      ]);
    } catch (e, st) {
      LogService.instance.error(
        'notifications.onboarding_failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  // =====================================================
  // 3. JOURNAL ENTRY FLOW
  // =====================================================
  Future<void> handleNewJournalEntry(String userId) async {
    try {
      await _engine.notifyInsight(
        userId: userId,
        title: 'Nuevo registro',
        message: 'Has escrito una nueva entrada',
      );
    } catch (e, st) {
      LogService.instance.error(
        'notifications.journal_failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  // =====================================================
  // 4. CHALLENGE FLOW
  // =====================================================
  Future<void> onChallengeStarted(String userId, String title) async {
    await _engine.notifyChallengeStarted(
      userId: userId,
      challengeTitle: title,
    );
  }

  Future<void> onChallengeCompleted(
    String userId,
    String title,
    int points,
  ) async {
    await _engine.notifyChallengeCompleted(
      userId: userId,
      challengeTitle: title,
      rewardPoints: points,
    );
  }

}