import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class DashboardNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int notificationCount;

  const DashboardNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.notificationCount = 0,
  });

  static const _items = [
    (
      icon: Icons.home_rounded,
      label: "Inicio",
    ),
    (
      icon: Icons.auto_awesome_rounded,
      label: "Explorar",
    ),
    (
      icon: Icons.add_rounded,
      label: "Crear",
    ),
    (
      icon: Icons.notifications_rounded,
      label: "Alerts",
    ),
    (
      icon: Icons.person_rounded,
      label: "Perfil",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final primary =
        Theme.of(context).colorScheme.primary;

    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AlmaRadius.xxl),
              // =====================
              // SHADOW
              // =====================
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(
                    alpha: .10,
                  ),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(0, 12),
                ),
              ],
        ),

    child: ClipRRect(
          borderRadius: BorderRadius.circular(
            AlmaRadius.xxl,
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 22,
              sigmaY: 22,
            ),
            child: Container(
              height: 74,
              padding: const EdgeInsets.symmetric(
                horizontal: AlmaSpacing.md,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  AlmaRadius.xxl,
                ),

                // =====================
                // GLASS
                // =====================
                color: AlmaColors.glass(isDark),

                border: Border.all(
                  color: AlmaColors.border(
                    isDark,
                  ),
                ),
              ),

              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                children: List.generate(
                  _items.length,
                  (index) {
                    final item = _items[index];

                    final selected =
                        currentIndex == index;

                    return _NavbarItem(
                      icon: item.icon,
                      label: item.label,
                      selected: selected,
                      primary: primary,
                      isDark: isDark,
                      showBadge:
                          index == 3 &&
                          notificationCount > 0,
                      badge:
                          notificationCount > 9
                              ? '9+'
                              : notificationCount
                                    .toString(),
                      onTap: () => onTap(index),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        );
      
  }
}

class _NavbarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool isDark;
  final Color primary;
  final VoidCallback onTap;
  final bool showBadge;
  final String badge;

  const _NavbarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.isDark,
    required this.primary,
    required this.onTap,
    this.showBadge = false,
    this.badge = '',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 220,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AlmaSpacing.md,
          vertical: AlmaSpacing.sm,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            AlmaRadius.xl,
          ),
          color: selected
              ? primary.withValues(alpha: .14)
              : AlmaColors.transparent,
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: selected
                      ? primary
                      : AlmaColors.textMuted(
                          isDark,
                        ),
                ),

                // =================
                // BADGE
                // =================
                if (showBadge)
                  Positioned(
                    top: -6,
                    right: -10,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AlmaColors.error,
                        borderRadius:
                            BorderRadius.circular(
                          AlmaRadius.full,
                        ),
                      ),
                      constraints:
                          const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Center(
                        child: Text(
                          badge,
                          style:
                              AlmaTypography
                                  .labelSmall(
                            isDark,
                          ).copyWith(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.w700,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(
              height: AlmaSpacing.xs,
            ),

            AnimatedOpacity(
              duration: const Duration(
                milliseconds: 180,
              ),
              opacity: selected ? 1 : .7,
              child: Text(
                label,
                style:
                    AlmaTypography.labelSmall(
                  isDark,
                ).copyWith(
                  color: selected
                      ? primary
                      : AlmaColors.textMuted(
                          isDark,
                        ),
                  fontWeight: selected
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}