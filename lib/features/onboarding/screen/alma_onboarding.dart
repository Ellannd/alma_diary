import 'package:flutter/material.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';
import 'package:flutter_svg/svg.dart';

class AlmaOnboarding extends StatelessWidget {
  final VoidCallback onFinish;

  const AlmaOnboarding({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AlmaColors.background(isDark),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AlmaSpacing.r(context, AlmaSpacing.lg),
          ),
          child: Column(
            children: [
              // Botón salir top right
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: onFinish,
                  icon: Icon(
                    Icons.door_front_door_outlined,
                    color: AlmaColors.textMuted(isDark),
                  ),
                ),
              ),

              const Spacer(),

              // Logo corazón partido
              SizedBox(
                width: AlmaSpacing.r(context, 270),
                height: AlmaSpacing.r(context, 270),
                child: Stack(
                  children: [
                    SvgPicture.asset(
                        'logo/logo.svg',
                        width: 250,
                        height: 250,
                      ),

                  ],
                ),
              ),

              SizedBox(height: AlmaSpacing.r(context, AlmaSpacing.xxl)),

              // Título
              Text(
                'Alma - Diario',
                style: AlmaTypography.displayLarge(isDark, context).copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 36,
                  letterSpacing: -0.5,
                ),
              ),

              SizedBox(height: AlmaSpacing.r(context, AlmaSpacing.sm)),

              // Subtítulo
              Text(
                'Escribe, sana, vive.',
                style: AlmaTypography.bodyLarge(isDark, context).copyWith(
                  color: AlmaColors.textSecondary(isDark),
                  fontWeight: FontWeight.w400,
                ),
              ),

              const Spacer(),

              // Botón Comenzar
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: onFinish,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AlmaColors.surfaceVariant(isDark),
                    foregroundColor: AlmaColors.textPrimary(isDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AlmaRadius.full),
                    ),
                  ),
                  child: Text(
                    'Comenzar',
                    style: AlmaTypography.labelLarge(isDark, context).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              SizedBox(height: AlmaSpacing.r(context, AlmaSpacing.lg)),
            ],
          ),
        ),
      ),
    );
  }
}
