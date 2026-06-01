// lib/design_system/components/feedback/alma_loader.dart

import 'package:flutter/material.dart';
import 'package:flutter_modern_animated_loader/flutter_animated_loader.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';

class AlmaLoader extends StatelessWidget {
   final double size;
  final Color? color;

  const AlmaLoader({super.key, this.size = 40, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FlutterAnimatedLoader.arcTrio( 
      color: color ?? AlmaColors.textPrimary(isDark),
      size: size,
    );
  }
}