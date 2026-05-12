import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:alma_diary/design_system/tokens/alma_colors.dart';

class DashboardBackground extends StatelessWidget {
  final Widget child;

  const DashboardBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AlmaColors.darkBackground,
                  AlmaColors.darkSurface,
                  AlmaColors.darkBackground,
                ]
              : [
                  AlmaColors.lightBackground,
                  AlmaColors.lightSurface,
                  AlmaColors.lightBackground,
                ],
        ),
      ),
      child: Stack(
        children: [
          // =========================
          // ORBS / GLOWS
          // =========================
          Positioned(
            top: -120,
            left: -80,
            child: _BlurOrb(
              size: 260,
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: .22),
            ),
          ),

          Positioned(
            top: 120,
            right: -100,
            child: _BlurOrb(
              size: 220,
              color: Colors.cyan.withValues(alpha: .12),
            ),
          ),

          Positioned(
            bottom: -140,
            left: 20,
            child: _BlurOrb(
              size: 300,
              color: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withValues(alpha: .16),
            ),
          ),

          // =========================
          // GLASS LAYER
          // =========================
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 80,
              sigmaY: 80,
            ),
            child: Container(
              color: Colors.transparent,
            ),
          ),

          // =========================
          // CONTENT SOLO (SIN SAFEAREA)
          // =========================
          child,
        ],
      ),
    );
  }
}

class _BlurOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurOrb({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 120,
          sigmaY: 120,
        ),
        child: const SizedBox(),
      ),
    );
  }
}