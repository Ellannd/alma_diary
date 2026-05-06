import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alma_diary/features/notifications/engine/notifications_engine.dart';
import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/models/alma_notification.dart';
import 'package:alma_diary/services/supabase_service.dart';
import "package:alma_diary/state/controllers/notifications_controller.dart";


/// =========================
/// PROVIDER ENGINE
/// =========================
final notificationEngineProvider = Provider<AlmaNotificationEngine>((ref) {
  final client = SupabaseService.instance.client;
  return AlmaNotificationEngine(client);
});

final notificationProvider =
    NotifierProvider<NotificationController, NotificationState>(
  NotificationController.new,
);
/// =========================
/// STATE
/// =========================
class NotificationState {
  final List<AlmaNotification> notifications;
  final int unreadCount;
  final bool loading;
  final String? error;
  final String? userId;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.loading = false,
    this.error,
    this.userId,
  });

  NotificationState copyWith({
    List<AlmaNotification>? notifications,
    int? unreadCount,
    bool? loading,
    String? error,
    String? userId,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      loading: loading ?? this.loading,
      error: error,
      userId: userId ?? this.userId,
    );
  }
}