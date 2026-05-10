import 'package:flutter/material.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class SettingsReportTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingsReportTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AlmaRadius.md),
      child: Container(
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
            Icon(
              Icons.description,
              size: 24,
              color: AlmaColors.accent(isDark),
            ),
            const SizedBox(width: AlmaSpacing.md),

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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: AlmaSpacing.xs),

            Icon(
              Icons.chevron_right,
              size: 20,
              color: AlmaColors.textMuted(isDark),
            ),
          ],
        ),
      ),
    );
  }
}