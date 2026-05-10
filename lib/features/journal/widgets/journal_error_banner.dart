import 'package:flutter/material.dart';

import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class JournalErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const JournalErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AlmaSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AlmaColors.error.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(
          AlmaRadius.lg,
        ),
        border: Border.all(
          color: AlmaColors.error.withValues(alpha: .24),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AlmaColors.error,
          ),

          const SizedBox(width: AlmaSpacing.sm),

          Expanded(
            child: Text(
              message,
              style:
                  AlmaTypography.bodyMedium(isDark),
            ),
          ),

          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(
                Icons.close_rounded,
              ),
            ),
        ],
      ),
    );
  }
}