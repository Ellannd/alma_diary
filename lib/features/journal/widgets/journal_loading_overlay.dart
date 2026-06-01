import 'package:alma_diary/design_system/components/feedback/alma_loader.dart';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class JournalLoadingOverlay extends StatelessWidget {
  final String label;

  const JournalLoadingOverlay({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 8,
          sigmaY: 8,
        ),
        child: Container(
          color: Colors.black.withValues(alpha: .20),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(
                AlmaSpacing.xl,
              ),
              decoration: BoxDecoration(
                color: AlmaColors.surface(isDark)
                    .withValues(alpha: .90),
                borderRadius: BorderRadius.circular(
                  AlmaRadius.xl,
                ),
                border: Border.all(
                  color: AlmaColors.border(isDark),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AlmaLoader(
                    color:
                        Theme.of(context).colorScheme.primary,
                  ),

                  const SizedBox(
                    height: AlmaSpacing.lg,
                  ),

                  Text(
                    label,
                    style:
                        AlmaTypography.bodyMedium(
                      isDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
