import 'package:flutter/material.dart';

import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class JournalEmptyState extends StatelessWidget {
  final VoidCallback? onTap;

  const JournalEmptyState({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final primary =
        Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AlmaSpacing.xl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withValues(alpha: .12),
              ),
              child: Icon(
                Icons.auto_stories_rounded,
                size: 54,
                color: primary,
              ),
            ),

            const SizedBox(
              height: AlmaSpacing.xl,
            ),

            Text(
              'Tu diario está vacío',
              textAlign: TextAlign.center,
              style: AlmaTypography.h2(isDark)
                  .copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: AlmaSpacing.md,
            ),

            Text(
              'Escribir puede ayudarte a comprender lo que sientes.',
              textAlign: TextAlign.center,
              style:
                  AlmaTypography.bodyMedium(isDark)
                      .copyWith(
                color:
                    AlmaColors.textSecondary(
                  isDark,
                ),
                height: 1.5,
              ),
            ),

            const SizedBox(
              height: AlmaSpacing.xl,
            ),

            ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.edit_rounded),
              label: const Text('Escribir entrada'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: AlmaSpacing.lg,
                  vertical: AlmaSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    AlmaRadius.full,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}