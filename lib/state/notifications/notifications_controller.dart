import 'package:alma_diary/state/profile/profile_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alma_diary/features/notifications/engine/notifications_engine.dart';
import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/models/alma_notification.dart';
import "package:alma_diary/state/notifications/notification_state.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:alma_diary/state/auth/auth_controller.dart";


//
//  PROVIDER
//
final notificationEngineProvider = Provider<AlmaNotificationEngine>((ref) {
  final client = Supabase.instance.client;
  return AlmaNotificationEngine(client);
});

final notificationControllerProvider =
    NotifierProvider<NotificationController, NotificationState>(
  NotificationController.new,
);
//
//  CONTROLLER
//
class NotificationController extends Notifier<NotificationState> {
  late final AlmaNotificationEngine _engine;

@override
NotificationState build() {
  _engine = ref.read(notificationEngineProvider);

  // Escuchar cambios de auth y actualizar userId automáticamente
  ref.listen(authControllerProvider, (_, next) {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId != null && state.userId != userId) {
      state = state.copyWith(userId: userId);
    }
  });

  final userId = ref.read(currentUserProvider)?.id;

  return NotificationState(userId: userId);
}

  void setUserId(String userId) {
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

        state = state.copyWith(
        notifications: state.notifications
            .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
            .toList(),
        unreadCount: (state.unreadCount - 1).clamp(0, 999),
      );
    } catch (e, st) {
      LogService.instance.error(
        'notifications.mark_read_failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      final result = await _engine.markAllAsRead(userId);
      if (!result.isValid) return;

    
      state = state.copyWith(
        notifications: state.notifications
            .map((n) => n.copyWith(isRead: true))
            .toList(),
        unreadCount: 0, 
      );
    } catch (e, st) {
      LogService.instance.error(
        'notifications.mark_all_read_failed',
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
  setUserId(userId);

  try {
    final results = await Future.wait([
      _engine.generateDailyQuote(userId),
      _engine.trackLoginEvent(userId),
      _engine.generateDailyReminder(userId),
    ]);

    // Enviar push solo si el daily reminder se generó (no existía ya hoy)
    final reminderResult = results[2];
    if (reminderResult.isValid) {
      await _engine.sendPush(
        userId: userId,
        title: 'Tu momento contigo',
        body: 'Escribe tu entrada de hoy ✍️',
      );
    }

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
      
       if (state.userId == null) {
    state = state.copyWith(userId: userId);
  }

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

  Future<void> handleChallengeEventDevice({
    required String userId,
    required String title,
    String eventType = 'started',
    int points = 0,
  }) async {
    try {
     
      if (eventType == 'started') {
        await _engine.notifyChallengeStarted(
          userId: userId,
          challengeTitle: title,
        );

        await _engine.sendPush(
          userId: userId,
          title: 'Nuevo desafío iniciado',
          body: title,
        );
      }

     
      if (eventType == 'completed') {
        await _engine.notifyChallengeCompleted(
          userId: userId,
          challengeTitle: title,
          rewardPoints: points,
        );

        await _engine.sendPush(
          userId: userId,
          title: 'Desafío completado 🎉',
          body: '$title (+$points pts)',
        );
      }

      await load();
    } catch (e, st) {
      LogService.instance.error(
        'notification.challenge_device_failed',
        error: e,
        stackTrace: st,
      );

      state = state.copyWith(
        error: 'Error enviando notificación',
      );
    }
  }
}