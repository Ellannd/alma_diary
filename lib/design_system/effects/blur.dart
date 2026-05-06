import 'dart:ui';
import 'package:flutter/material.dart';

class AlmaBlur extends StatelessWidget {
  final Widget child;
  final double sigmaX;
  final double sigmaY;
  final BorderRadius? borderRadius;
  final bool enabled;

  const AlmaBlur({
    super.key,
    required this.child,
    this.sigmaX = 12,
    this.sigmaY = 12,
    this.borderRadius,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    Widget content = BackdropFilter(
      filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
      child: child,
    );

    if (borderRadius != null) {
      content = ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }

    return content;
  }
}