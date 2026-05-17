import 'package:flutter/material.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class ProfileJourneyCard extends StatelessWidget {
  final String? painPoint;
  final String? hopefulGoal;

  const ProfileJourneyCard({
    super.key,
    this.painPoint,
    this.hopefulGoal,
  });

  String _format(String? value) {
    if (value == null) return 'Sin definir';
    return value.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (painPoint == null) return const SizedBox();

    return Container(
      padding: EdgeInsets.all(AlmaSpacing.lg),
      decoration: BoxDecoration(
        color: AlmaColors.surface(isDark),
        borderRadius: BorderRadius.circular(AlmaRadius.lg),
        border: Border.all(
          color: AlmaColors.glass(isDark).withValues(alpha: 0.60),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu viaje',
            style: AlmaTypography.h3(isDark),
          ),

          SizedBox(height: AlmaSpacing.sm),

          Text(
            'Trabajas en: ${_format(painPoint)}',
            style: AlmaTypography.bodyMedium(isDark),
          ),

          if (hopefulGoal != null) ...[
            SizedBox(height: AlmaSpacing.xs),
            Text(
              'Buscas: ${_format(hopefulGoal)}',
              style: AlmaTypography.bodySmall(isDark).copyWith(
                color: AlmaColors.textMuted(isDark),
              ),
            ),
          ],
        ],
      ),
    );
  }
}