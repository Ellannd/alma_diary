import 'package:alma_diary/models/alma_notification.dart';

enum NotificationAction {
  createJournal,
  openTrajectory,
  openChallenges,
  none,
}

class NotificationActionMapper {
  static NotificationAction fromNotification(
    AlmaNotification notification,
  ) {
    final route = notification.actionRoute;

    if (route != null) {
      switch (route) {
        case '/create':
          return NotificationAction.createJournal;

        case '/trajectory':
          return NotificationAction.openTrajectory;

        case '/challenges':
          return NotificationAction.openChallenges;

        default:
          return NotificationAction.none;
      }
    }

    switch (notification.action) {
      case 'Escribir ahora':
        return NotificationAction.createJournal;

      case 'Revisar trayectoria':
        return NotificationAction.openTrajectory;

      case 'Ver desafíos':
        return NotificationAction.openChallenges;

      default:
        return NotificationAction.none;
    }
  }
}