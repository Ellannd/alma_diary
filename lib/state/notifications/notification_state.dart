import "package:alma_diary/models/alma_notification.dart";
class NotificationState {
  final List<AlmaNotification> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? userId;
  final String? error;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.userId,
    this.error,
  });

  NotificationState copyWith({
    List<AlmaNotification>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? userId,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      userId: userId ?? this.userId,
      error: error,
    );
  }

  factory NotificationState.initial() => const NotificationState();
}