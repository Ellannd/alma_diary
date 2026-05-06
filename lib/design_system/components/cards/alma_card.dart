import 'dart:ui';
import 'package:flutter/material.dart';

enum AlmaCardVariant { solid, glass, outlined }

class AlmaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final AlmaCardVariant variant;
  final VoidCallback? onTap;

  const AlmaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.variant = AlmaCardVariant.solid,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final content = _buildVariant(context, isDark);

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: content,
      ),
    );
  }

  Widget _buildVariant(BuildContext context, bool isDark) {
    switch (variant) {
      case AlmaCardVariant.solid:
        return Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child,
        );

      case AlmaCardVariant.outlined:
        return Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.08),
            ),
          ),
          child: child,
        );

      case AlmaCardVariant.glass:
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: .05)
                    : Colors.white.withValues(alpha: .6),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.4),
                ),
              ),
              child: child,
            ),
          ),
        );
    }
  }
}