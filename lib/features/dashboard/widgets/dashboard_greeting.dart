import 'package:flutter/material.dart';

import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
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

    if (hour < 12) {
      return "Buenos días";
    }

    if (hour < 18) {
      return "Buenas tardes";
    }

    return "Buenas noches";
  }

  IconData _icon() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return Icons.wb_sunny_rounded;
    }

    if (hour < 18) {
      return Icons.cloud_rounded;
    }

    return Icons.nights_stay_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final primary =
        Theme.of(context).colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // =========================
        // AVATAR / AMBIENT ICON
        // =========================
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AlmaRadius.xl,
            ),
            color: primary.withValues(alpha: .14),
            border: Border.all(
              color: primary.withValues(alpha: .18),
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: .14),
                blurRadius: 24,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            _icon(),
            color: primary,
            size: 30,
          ),
        ),

        const SizedBox(width: AlmaSpacing.md),

        // =========================
        // TEXT
        // =========================
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                "${_greeting()},",
                style:
                    AlmaTypography.bodyMedium(
                  isDark,
                ).copyWith(
                  color:
                      AlmaColors.textSecondary(
                    isDark,
                  ),
                ),
              ),

              const SizedBox(
                height: AlmaSpacing.xs,
              ),

              Text(
                userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    AlmaTypography.displayMedium(
                  isDark,
                ).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: AlmaSpacing.xs,
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: AlmaSpacing.sm,
                  vertical: AlmaSpacing.xs,
                ),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(
                    AlmaRadius.full,
                  ),
                  color: primary.withValues(
                    alpha: .10,
                  ),
                  border: Border.all(
                    color: primary.withValues(
                      alpha: .12,
                    ),
                  ),
                ),
                child: Text(
                  archetype,
                  style:
                      AlmaTypography.labelSmall(
                    isDark,
                  ).copyWith(
                    color: primary,
                    fontWeight:
                        FontWeight.w600,
                    letterSpacing: .4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}