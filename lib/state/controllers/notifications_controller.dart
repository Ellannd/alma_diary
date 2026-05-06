import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alma_diary/features/notifications/engine/notifications_engine.dart';
import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/models/alma_notification.dart';
import "package:alma_diary/state/providers/notifications_provider.dart";

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

    state = state.copyWith(loading: true, error: null);

    try {
      final data = await _engine.fetchUserNotifications(userId);

      final notifications =
          data.map((e) => AlmaNotification.fromMap(e)).toList();

      final unread = await _engine.getUnreadCount(userId);

      state = state.copyWith(
        notifications: notifications,
        unreadCount: unread,
        loading: false,
      );
    } catch (e, st) {
      LogService.instance.error(
        'notifications.load_failed',
        error: e,
        stackTrace: st,
      );

      state = state.copyWith(
        loading: false,
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

  Future<void> reset() async {
    state = const NotificationState();
  }
}