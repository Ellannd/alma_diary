
import 'package:flutter/material.dart';

import 'package:alma_diary/design_system/tokens/alma_colors.dart';

class NotificationColorMapper {
  static Color fromKey(
    String key,
    bool isDark,
  ) {
    switch (key) {
      //todo dont hardcode colors
      case 'orange':
        return Colors.orange;

      case 'purple':
        return Colors.purple;

      case 'green':
        return Colors.green;

      case 'amber':
        return Colors.amber;

      default:
        return AlmaColors.accent(isDark);
    }
  }
}