import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class DashboardSection extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const DashboardSection({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AlmaSpacing.lg),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AlmaRadius.lg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: AlmaColors.glass(isDark),
              borderRadius: BorderRadius.circular(AlmaRadius.lg),
              border: Border.all(
                color: AlmaColors.border(isDark),
              ),
            ),
            padding: const EdgeInsets.all(AlmaSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER SECTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: AlmaTypography.h2(isDark),
                    ),
                    ?trailing,
                  ],
                ),

                const SizedBox(height: AlmaSpacing.md),

                /// CONTENT
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}