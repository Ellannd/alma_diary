import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class DashboardMoodCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String mood;
  final Icon icon;
  final VoidCallback? onTap;

  const DashboardMoodCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.mood,
    required this.icon,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final primary =
        Theme.of(context).colorScheme.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(
        AlmaRadius.xl,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 4,
          sigmaY: 4,
        ),
        child: Container(
          padding: const EdgeInsets.all(
            AlmaSpacing.lg,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AlmaRadius.xl,
            ),

            // =========================
            // GLASS
            // =========================
            color: AlmaColors.transparent,

            border: Border.all(
              color: AlmaColors.border(
                isDark,
              ),
            ),


          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // =====================
              // TOP
              // =====================
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(
                        AlmaRadius.lg,
                      ),
                      color: primary.withValues(
                        alpha: .14,
                      ),
                    ),
                    child: icon,
                  ),

                  const Spacer(),

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
                    ),
                    child: Text(
                      mood,
                      style:
                          AlmaTypography.labelMedium(
                        isDark,
                      ).copyWith(
                        color: primary,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: AlmaSpacing.lg,
              ),

              // =====================
              // TITLE
              // =====================
              Text(
                title,
                style: AlmaTypography.h2(
                  isDark,
                ).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: AlmaSpacing.sm,
              ),

              // =====================
              // SUBTITLE
              // =====================
              Text(
                subtitle,
                style:
                    AlmaTypography.bodyMedium(
                  isDark,
                ).copyWith(
                  color:
                      AlmaColors.textSecondary(
                    isDark,
                  ),
                  height: 1.5,
                ),
              ),

              const SizedBox(
                height: AlmaSpacing.lg,
              ),

              // =====================
              // CTA
              // =====================
              GestureDetector(
                onTap: onTap,
                child: Row(
                  children: [
                    Text(
                      "Continuar",
                      style:
                          AlmaTypography.dashboardSecondary(
                        isDark,
                      ).copyWith(
                        color: primary,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
