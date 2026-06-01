import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:flutter/material.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';


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
                  Image.asset(
              'assets/logo/logo_1.png',
              width: 340,
              height: 340,
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