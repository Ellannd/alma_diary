import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class DashboardQuoteCard extends StatelessWidget {
  final String quote;
  final String author;

  const DashboardQuoteCard({
    super.key,
    required this.quote,
    required this.author,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AlmaRadius.lg),
      child: Stack(
        children: [
          // Background gradient
          Container(
            padding: const EdgeInsets.all(AlmaSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AlmaColors.accent(isDark).withValues(alpha: 0.25),
                  AlmaColors.accentSoft(isDark).withValues(alpha: 0.10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 🌫 Glass blur layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.all(AlmaSpacing.lg),
              decoration: BoxDecoration(
                color: AlmaColors.surface(isDark).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AlmaRadius.lg),
                border: Border.all(
                  color: AlmaColors.border(isDark),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label
                  Text(
                    "Reflexión del día",
                    style: AlmaTypography.labelSmall(isDark).copyWith(
                      color: AlmaColors.textMuted(isDark),
                    ),
                  ),

                  const SizedBox(height: AlmaSpacing.sm),

                  // Quote
                  Text(
                    quote,
                    style: AlmaTypography.quote(isDark),
                  ),

                  const SizedBox(height: AlmaSpacing.md),

                  // Author (NEW)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "— $author",
                      style: AlmaTypography.labelMedium(isDark).copyWith(
                        color: AlmaColors.textSecondary(isDark),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}