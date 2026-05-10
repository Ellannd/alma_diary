enum NotificationActionType {
  create,
  trajectory,
  challenge,
  reflection,
  custom,
}

class NotificationAction {
  final NotificationActionType type;
  final String label;
  final String? route;

  const NotificationAction({
    required this.type,
    required this.label,
    this.route,
  });
}