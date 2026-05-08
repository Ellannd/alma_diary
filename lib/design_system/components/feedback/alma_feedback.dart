import 'package:flutter/material.dart';
import "package:alma_diary/design_system/tokens/alma_colors.dart";

enum AlmaFeedbackType {
  error,
  success,
  warning,
  info,
}

class AlmaFeedback extends StatelessWidget {
  final String message;
  final AlmaFeedbackType type;

  const AlmaFeedback({
    super.key,
    required this.message,
    this.type = AlmaFeedbackType.info,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStyle(type);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(config.icon, color: config.color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: config.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _FeedbackStyle _getStyle(AlmaFeedbackType type) {
    switch (type) {
      case AlmaFeedbackType.error:
        return _FeedbackStyle(
          color: AlmaColors.error,
          background: AlmaColors.error.withValues(alpha: 0.1),
          icon: Icons.error_outline,
        );

      case AlmaFeedbackType.success:
        return _FeedbackStyle(
          color: AlmaColors.success,
          background: AlmaColors.success.withValues(alpha: .1),
          icon: Icons.check_circle_outline,
        );

      case AlmaFeedbackType.warning:
        return _FeedbackStyle(
          color: AlmaColors.warning,
          background: AlmaColors.warning.withValues(alpha: .1),
          icon: Icons.warning_amber_rounded,
        );

      case AlmaFeedbackType.info:
        return _FeedbackStyle(
          color: AlmaColors.info,
          background: AlmaColors.info.withValues(alpha: .1),
          icon: Icons.info_outline,
        );
    }
  }
}

class _FeedbackStyle {
  final Color color;
  final Color background;
  final IconData icon;

  _FeedbackStyle({
    required this.color,
    required this.background,
    required this.icon,
  });
}

class AlmaFeedbackHelper {
  static Widget error(String msg) =>
      AlmaFeedback(message: msg, type: AlmaFeedbackType.error);

  static Widget success(String msg) =>
      AlmaFeedback(message: msg, type: AlmaFeedbackType.success);

  static Widget warning(String msg) =>
      AlmaFeedback(message: msg, type: AlmaFeedbackType.warning);

  static Widget info(String msg) =>
      AlmaFeedback(message: msg, type: AlmaFeedbackType.info);
}