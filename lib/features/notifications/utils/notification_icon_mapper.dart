// utils/notification_icon_mapper.dart

import 'package:flutter/material.dart';

class NotificationIconMapper {
  static IconData fromKey(String key) {
    switch (key) {
      case 'schedule':
        return Icons.schedule_rounded;

      case 'psychology':
        return Icons.psychology_rounded;

      case 'emoji_events':
        return Icons.emoji_events_rounded;

      case 'celebration':
        return Icons.celebration_rounded;

      case 'favorite':
        return Icons.favorite_rounded;

      default:
        return Icons.notifications_rounded;
    }
  }
}