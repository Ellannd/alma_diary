// dashboard_feature_card.dart
import 'package:flutter/material.dart';

import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';

class DashboardFeatureCard extends StatefulWidget {
  final IconData icon;
  final Color cardColor;
  final VoidCallback onTap;

  const DashboardFeatureCard({
    super.key,
    required this.icon,
    required this.cardColor,
    required this.onTap,
  });

  @override
  State<DashboardFeatureCard> createState() =>
      _DashboardFeatureCardState();
}

class _DashboardFeatureCardState
    extends State<DashboardFeatureCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _saturation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _saturation = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.forward();
  void _onTapUp(_) {
    _controller.reverse();
    widget.onTap();
  }
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix(
                _saturationMatrix(_saturation.value),
              ),
              child: child,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AlmaRadius.ftcard),
            color: isDark
                ? widget.cardColor.withValues(alpha: .85)
                : widget.cardColor,
          ),
          padding: const EdgeInsets.all(AlmaSpacing.lg),
            child: Center(
                child: Icon(
                  widget.icon,
                  size: 60,
                  color: Colors.white.withValues(alpha: .90),
                ),
              ),
 
        ),
      ),
    );
  }

  // Matriz de saturación — 1.0 = normal, >1.0 = más saturado
  List<double> _saturationMatrix(double sat) {
    final r = 0.213 + 0.787 * sat;
    final g = 0.715 - 0.715 * sat;
    final b = 0.072 - 0.072 * sat;
    final r2 = 0.213 - 0.213 * sat;
    final g2 = 0.715 + 0.285 * sat;
    final b2 = 0.072 - 0.072 * sat;
    final r3 = 0.213 - 0.213 * sat;
    final g3 = 0.715 - 0.715 * sat;
    final b3 = 0.072 + 0.928 * sat;

    return [
      r,  g,  b,  0, 0,
      r2, g2, b2, 0, 0,
      r3, g3, b3, 0, 0,
      0,  0,  0,  1, 0,
    ];
  }
}