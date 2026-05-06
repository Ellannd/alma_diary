import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alma_diary/features/notifications/engine/notifications_engine.dart';
import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/models/alma_notification.dart';
import "package:alma_diary/state/notifications/notifications_provider.dart";
import "package:alma_diary/state/notifications/notification_state.dart";

class NotificationController extends Notifier<NotificationState> {
  late final AlmaNotificationEngine _engine;

  @override
  NotificationState build() {
    _engine = ref.read(notificationEngineProvider);
    return const NotificationState();
  }

  void setUser(String userId) {
    state = state.copyWith(userId: userId);
  }

  Future<void> load() async {
    final userId = state.userId;
    if (userId == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _engine.fetchUserNotifications(userId);

      final notifications =
          data.map((e) => AlmaNotification.fromMap(e)).toList();

      final unread = await _engine.getUnreadCount(userId);

      state = state.copyWith(
        notifications: notifications,
        unreadCount: unread,
        isLoading: false,
      );
    } catch (e, st) {
      LogService.instance.error(
        'notifications.load_failed',
        error: e,
        stackTrace: st,
      );

      state = state.copyWith(
        isLoading: false,
        error: 'Error cargando notificaciones',
      );
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final result = await _engine.markAsRead(id);

      if (!result.isValid) return;

      await load();
    } catch (e, st) {
      LogService.instance.error(
        'notifications.mark_read_failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> ensureLoaded() async {
    if (state.notifications.isNotEmpty) return;
    await load();
  }

  Future<void> handlePostLogin(String userId) async {
    setUser(userId);

    try {
      await Future.wait([
        _engine.generateDailyQuote(userId),
        _engine.trackLoginEvent(userId),
        _engine.generateDailyReminder(userId),
      ]);

      await load();
    } catch (e, st) {
      LogService.instance.error(
        'notifications.post_login_failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> handleOnboardingCompleted(String userId) async {
    try {
      await _engine.notifyInsight(
        userId: userId,
        title: 'Bienvenido a Alma',
        message: 'Tu viaje ha comenzado',
      );

      await load();
    } catch (e) {
      LogService.instance.error('notifications.onboarding_failed', error: e);
    }
  }

  Future<void> handleNewJournalEntry(String userId) async {
    try {
      await _engine.notifyInsight(
        userId: userId,
        title: 'Nuevo registro',
        message: 'Has escrito una nueva entrada',
      );

      await load();
    } catch (e) {
      LogService.instance.error('notifications.journal_failed', error: e);
    }
  }

  Future<void> handleChallengeEvent(
      String userId,
      String title, {
      String eventType = 'started',
      int points = 0,
    }) async {
      try {
        LogService.instance.info(
          'notifications.challenge_event.start',
          context: {
            'userId': userId,
            'eventType': eventType,
            'title': title,
            'points': points,
          },
        );

        final result = eventType == 'started'
            ? await _engine.notifyChallengeStarted(
                userId: userId,
                challengeTitle: title,
              )
            : await _engine.notifyChallengeCompleted(
                userId: userId,
                challengeTitle: title,
                rewardPoints: points,
              );

        if (!result.isValid) {
          LogService.instance.warning(
            'notifications.challenge_event.failed',
            context: {'error': result.error},
          );

          state = state.copyWith(
            error: 'No se pudo generar la notificación',
          );

          return;
        }

        // refresh state
        await load();

        LogService.instance.info(
          'notifications.challenge_event.success',
          context: {
            'userId': userId,
            'eventType': eventType,
          },
        );
      } catch (e, st) {
        LogService.instance.error(
          'notifications.challenge_event.error',
          error: e,
          stackTrace: st,
          context: {
            'userId': userId,
            'eventType': eventType,
            'title': title,
          },
        );

        state = state.copyWith(
          error: 'Error procesando evento de desafío',
        );
      }
    }

  Future<void> reset() async {
    state = const NotificationState();
  }
}