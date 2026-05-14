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
      //label: "Inicio",
    ),
    (
      icon: Icons.search_rounded,
     // label: "Buscar",
    ),
    (
      icon: Icons.add_rounded,
      //label: "Crear",
    ),
    (
      icon: Icons.notifications_rounded,
     // label: "Alerts",
    ),
    (
      icon: Icons.person_rounded,
      //label: "Perfil",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AlmaRadius.navbar),
        ),

    child: ClipRRect(
          borderRadius: BorderRadius.circular(
            AlmaRadius.navbar,
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 18,
              sigmaY: 18,
            ),
            child: Container(
              height: 74,
              padding: const EdgeInsets.symmetric(
                horizontal: AlmaSpacing.md,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  AlmaRadius.navbar,
                ),

                // =====================
                // GLASS
                // =====================
                color: AlmaColors.transparent,

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
                      selected: selected,
                      primary: AlmaColors.navIcon(isDark),
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
  final bool selected;
  final bool isDark;
  final Color primary;
  final VoidCallback onTap;
  final bool showBadge;
  final String badge;

  const _NavbarItem({
    required this.icon,
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
      duration: const Duration(milliseconds: 220),
      width: 56,
      height: 56,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        color: selected
            ? AlmaColors.navbarHover
            : Colors.transparent,

        boxShadow: selected
            ? [
                BoxShadow(
                  color: AlmaColors.darkBackground.withValues(alpha: .18),
                  blurRadius: 12,
                  offset: const Offset(0, 10),
                ),

                // neumorphism highlight
                BoxShadow(
                  color: AlmaColors.lightBackground.withValues(alpha: .04),
                  blurRadius: 6,
                  offset: const Offset(-2, -2),
                ),
              ]
            : [],

        border: Border.all(
          color: selected
              ? AlmaColors.lightBackground.withValues(alpha: .04)
              : Colors.transparent,
        ),
      ),

      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              size: 28,
              color: selected
                  ? primary
                  : AlmaColors.textMuted(isDark),
            ),

            // =================
            // BADGE
            // =================
            if (showBadge)
              Positioned(
                top: -6,
                right: -10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AlmaColors.error,
                    borderRadius: BorderRadius.circular(
                      AlmaRadius.full,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      badge,
                      style: AlmaTypography.labelSmall(
                        isDark,
                      ).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
}