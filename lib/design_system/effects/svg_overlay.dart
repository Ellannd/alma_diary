import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AlmaSvgOverlay extends StatelessWidget {
  final String asset;
  final double opacity;
  final Alignment alignment;
  final BoxFit fit;
  final EdgeInsetsGeometry padding;

  const AlmaSvgOverlay({
    super.key,
    required this.asset,
    this.opacity = 0.05,
    this.alignment = Alignment.center,
    this.fit = BoxFit.cover,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final color = isDark
        ? Colors.white.withValues(alpha: opacity)
        : Colors.black.withValues(alpha: opacity);

    return IgnorePointer(
      child: Padding(
        padding: padding,
        child: Align(
          alignment: alignment,
          child: SvgPicture.asset(
            asset,
            fit: fit,
            colorFilter: ColorFilter.mode(
              color,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}