import 'package:flutter/material.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class SettingsNotificationsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsNotificationsTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
        padding: EdgeInsets.symmetric(
          horizontal: AlmaSpacing.md,
          vertical: AlmaSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AlmaColors.surfaceVariant(isDark),
          borderRadius: BorderRadius.circular(AlmaRadius.md),
          border: Border.all(
            color: AlmaColors.border(isDark),
            width: 1.0,
          ),
        ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AlmaTypography.bodyMedium(isDark).copyWith(
                    color: AlmaColors.textPrimary(isDark),
                  ),
                ),
                const SizedBox(height: AlmaSpacing.xs),
                Text(
                  subtitle,
                  style: AlmaTypography.bodySmall(isDark).copyWith(
                    color: AlmaColors.textMuted(isDark),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AlmaSpacing.md),

          Transform.scale(
            scale: 0.7,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AlmaColors.accent(isDark),

            ),
          ),
        ],
      ),
    );
  }
}