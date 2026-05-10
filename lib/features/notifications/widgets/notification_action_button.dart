// widgets/notification_action_button.dart

import 'package:flutter/material.dart';

import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class NotificationActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;

  const NotificationActionButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return SizedBox(
      height: 42,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor:
              color.withValues(alpha: .14),

          foregroundColor: color,

          padding:
              const EdgeInsets.symmetric(
            horizontal: AlmaSpacing.md,
          ),

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              AlmaRadius.full,
            ),
          ),
        ),
        child: Text(
          label,
          style:
              AlmaTypography.labelMedium(
            isDark,
          ).copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}