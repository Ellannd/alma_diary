// dashboard_greeting.dart
import 'package:flutter/material.dart';

import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class DashboardGreeting extends StatelessWidget {
  final String userName;
  final String archetype;

  const DashboardGreeting({
    super.key,
    required this.userName,
    required this.archetype,
  });

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Buenos días";
    if (hour < 18) return "Buenas tardes";
    return "Buenas noches";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(left: AlmaSpacing.xl),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // SALUDO PEQUEÑO
            // =========================
            Text(
              _greeting(),
              style: AlmaTypography.dashboardGreetingLight(isDark, context).copyWith(
                color: AlmaColors.textSecondary(isDark),
                fontSize: 30
              ),
            ),

            const SizedBox(height: AlmaSpacing.xxs),

            // =========================
            // NOMBRE GRANDE
            // =========================
            Text(
              userName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AlmaTypography.dashboardGreetingDark(isDark, context).copyWith(
                letterSpacing: -1.0,
              ),
            ),

            const SizedBox(height: AlmaSpacing.sm),

            // =========================
            // ARCHETYPE PILL
            // =========================
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AlmaSpacing.sm,
                vertical: AlmaSpacing.xs,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: primary.withValues(alpha: .10),
                border: Border.all(
                  color: primary.withValues(alpha: .18),
                ),
              ),
              child: Text(
                archetype,
                style: AlmaTypography.labelSmall(isDark).copyWith(
                  color: primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: .4,
                ),
              ),
            ),
          ],
        )
        );
      }
    }