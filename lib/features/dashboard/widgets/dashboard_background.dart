import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import "package:alma_diary/design_system/effects/svg_overlay.dart";

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
    final primary = Theme.of(context).colorScheme.primary;

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
          // ORBS
          // =========================
          Positioned(
            top: -120,
            left: -80,
            child: _BlurOrb(
              size: 260,
              color: primary.withValues(alpha: .22),
            ),
          ),
          Positioned(
            top: 120,
            right: -100,
            child: _BlurOrb(
              size: 220,
              color: Colors.cyan.withValues(alpha: .10),
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
                  .withValues(alpha: .14),
            ),
          ),

          // =========================
          // SVG OVERLAYS — estilo Picasso/minimalista
          // =========================
          
          Positioned(
            top: 40,
            right: 20,
            child: AlmaSvgOverlay(asset: "bg_overlay/picasso_1.svg")
          ),
          Positioned(
            bottom: 10,
            left: -50,
            child: AlmaSvgOverlay(asset: "bg_overlay/picasso_2.svg")
          ),

          // =========================
          // CONTENT
          // =========================
          child,
        ],
      ),
    );
  }
}

// =========================
// BLUR ORB
// =========================
class _BlurOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
        child: const SizedBox(),
      ),
    );
  }
}


