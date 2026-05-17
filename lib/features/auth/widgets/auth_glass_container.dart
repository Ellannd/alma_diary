import 'dart:ui';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:flutter/material.dart';

class AuthGlassContainer extends StatelessWidget {
  final Widget child;

  const AuthGlassContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          padding: EdgeInsets.all(AlmaSpacing.r(context,24)),
          decoration: BoxDecoration(
            color: AlmaColors.background(isDark),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AlmaColors.textPrimary(isDark).withValues(alpha: .8),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}