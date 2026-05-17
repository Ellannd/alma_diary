import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:flutter/material.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';
import 'package:flutter_svg/svg.dart';

class AuthTitle extends StatelessWidget {
  const AuthTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Logo corazón partido
        SizedBox(
          width: AlmaSpacing.r(context, 80),
          height: AlmaSpacing.r(context, 80),
          child: Stack(
            children: [
                 SvgPicture.asset(
            'logo/logo.svg',
            width: 450,
            height: 450,
          ),
            ],
          ),
        ),

        SizedBox(height: AlmaSpacing.r(context, 16)),

        Text(
          'Alma Diario',
          style: AlmaTypography.displayLarge(isDark, context).copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}