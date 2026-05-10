import 'package:flutter/material.dart';

import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class NotificationHeader
    extends StatelessWidget {
  final VoidCallback? onRefresh;

  const NotificationHeader({
    super.key,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AlmaSpacing.lg,
        vertical: AlmaSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Insights Alma',
              style:
                  AlmaTypography.h2(
                isDark,
              ).copyWith(
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),

          IconButton(
            onPressed: onRefresh,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
    );
  }
}