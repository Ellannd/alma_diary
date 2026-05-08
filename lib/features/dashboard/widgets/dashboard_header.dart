import 'package:flutter/material.dart';

import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';
import "dashboard_greeting.dart";

class DashboardHeader extends StatelessWidget {
  final String userName;
  final String archetype;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final int notificationCount;

  const DashboardHeader({
    super.key,
    required this.userName,
    required this.archetype,
    this.onProfileTap,
    this.onNotificationTap,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final primary =
        Theme.of(context).colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =========================
        // GREETING BLOCK
        // =========================
        Expanded(
          child: DashboardGreeting(
            userName: userName,
            archetype: archetype,
          ),
        ),

        const SizedBox(width: AlmaSpacing.md),

        // =========================
        // ACTIONS
        // =========================
        Row(
          children: [
            _HeaderButton(
              icon: Icons.notifications_none_rounded,
              primary: primary,
              isDark: isDark,
              badge: notificationCount,
              onTap: onNotificationTap,
            ),

            const SizedBox(width: AlmaSpacing.sm),

            _HeaderButton(
              icon: Icons.person_outline_rounded,
              primary: primary,
              isDark: isDark,
              onTap: onProfileTap,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final int badge;
  final bool isDark;
  final Color primary;

  const _HeaderButton({
    required this.icon,
    required this.primary,
    required this.isDark,
    this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                AlmaRadius.lg,
              ),
              color: AlmaColors.glass(isDark),
              border: Border.all(
                color: AlmaColors.border(
                  isDark,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: .10),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface,
              size: 24,
            ),
          ),

          // =========================
          // BADGE
          // =========================
          if (badge > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AlmaColors.error,
                  borderRadius:
                      BorderRadius.circular(
                    AlmaRadius.full,
                  ),
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Center(
                  child: Text(
                    badge > 9
                        ? "9+"
                        : badge.toString(),
                    style:
                        AlmaTypography.labelSmall(
                      isDark,
                    ).copyWith(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}