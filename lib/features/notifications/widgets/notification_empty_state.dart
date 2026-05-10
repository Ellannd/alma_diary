import 'package:flutter/material.dart';

import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class NotificationEmptyState
    extends StatelessWidget {
  const NotificationEmptyState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          AlmaSpacing.xl,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_rounded,
              size: 72,
              color:
                  AlmaColors.textMuted(
                isDark,
              ),
            ),

            const SizedBox(
              height: AlmaSpacing.lg,
            ),

            Text(
              'No hay notificaciones',
              style: AlmaTypography.h3(
                isDark,
              ),
            ),

            const SizedBox(
              height: AlmaSpacing.sm,
            ),

            Text(
              'Tu espacio está en calma por ahora.',
              textAlign: TextAlign.center,
              style:
                  AlmaTypography.bodyMedium(
                isDark,
              ).copyWith(
                color:
                    AlmaColors.textMuted(
                  isDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}