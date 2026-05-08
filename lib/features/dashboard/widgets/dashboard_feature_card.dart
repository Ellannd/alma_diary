import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class DashboardFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const DashboardFeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final primary = Theme.of(context).colorScheme.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(
        AlmaRadius.card,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              AlmaRadius.card,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.all(
                AlmaSpacing.lg,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  AlmaRadius.card,
                ),

                // =========================
                // GLASS SURFACE
                // =========================
                color: isDark
                    ? Colors.white.withValues(alpha: .05)
                    : Colors.white.withValues(alpha: .55),

                border: Border.all(
                  color: primary.withValues(alpha: .14),
                ),

                // =========================
                // SHADOWS / GLOW
                // =========================
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: .08),
                    blurRadius: 24,
                    spreadRadius: 1,
                    offset: const Offset(0, 10),
                  ),
                ],

                // =========================
                // SUBTLE GRADIENT
                // =========================
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primary.withValues(alpha: .08),
                    AlmaColors.transparent,
                  ],
                ),
              ),

              // =========================
              // CONTENT
              // =========================
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =====================
                  // ICON
                  // =====================
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(
                        AlmaRadius.lg,
                      ),
                      color: primary.withValues(
                        alpha: .14,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: primary,
                      size: 28,
                    ),
                  ),

                  const Spacer(),

                  // =====================
                  // TITLE
                  // =====================
                  Text(
                    title,
                    style: AlmaTypography.h3(
                      isDark,
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: AlmaSpacing.xs,
                  ),

                  // =====================
                  // SUBTITLE
                  // =====================
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AlmaTypography.bodyMedium(
                      isDark,
                    ).copyWith(
                      color: AlmaColors.textSecondary(
                        isDark,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: AlmaSpacing.md,
                  ),

                  // =====================
                  // FOOTER
                  // =====================
                  Row(
                    children: [
                      Text(
                        "Explorar",
                        style:
                            AlmaTypography.labelMedium(
                          isDark,
                        ).copyWith(
                          color: primary,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(
                        width: AlmaSpacing.xs,
                      ),

                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: primary,
                      ),
                    ],
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