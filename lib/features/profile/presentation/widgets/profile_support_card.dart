import 'package:flutter/material.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class ProfileSupportCard extends StatelessWidget {
  const ProfileSupportCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(AlmaSpacing.lg),
      decoration: BoxDecoration(
        color: AlmaColors.surface(isDark),
        borderRadius: BorderRadius.circular(AlmaRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Motor de Alma',
            style: AlmaTypography.h3(isDark),
          ),

          SizedBox(height: AlmaSpacing.sm),

          Text(
            'Tu experiencia es personalizada y privada. Usamos IA para acompañarte emocionalmente.',
            style: AlmaTypography.bodySmall(isDark).copyWith(
              color: AlmaColors.textMuted(isDark),
            ),
          ),
        ],
      ),
    );
  }
}