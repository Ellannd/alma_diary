import 'package:flutter/material.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class PersonalizedReadingCard extends StatelessWidget {
  final Map<String, String> data;
  final VoidCallback onSave;

  const PersonalizedReadingCard({
    super.key,
    required this.data,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(AlmaSpacing.cardPaddingR(context)),
      decoration: BoxDecoration(
        color: AlmaColors.surface(isDark),
        borderRadius: BorderRadius.circular(AlmaRadius.card),
        border: Border.all(
          color: AlmaColors.border(isDark).withValues(alpha: .12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge personalizado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AlmaColors.accentSoft(isDark),
              borderRadius: BorderRadius.circular(AlmaRadius.full),
            ),
            child: Text(
              'Para ti',
              style: AlmaTypography.labelSmall(isDark, context).copyWith(
                color: AlmaColors.accent(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: AlmaSpacing.r(context, AlmaSpacing.sm)),

          Text(
            data['title'] ?? '',
            style: AlmaTypography.h3(isDark, context),
          ),

          SizedBox(height: AlmaSpacing.r(context, AlmaSpacing.xs)),

          Text(
            data['content'] ?? '',
            style: AlmaTypography.bodySmall(isDark, context).copyWith(
              color: AlmaColors.textSecondary(isDark),
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: AlmaSpacing.r(context, AlmaSpacing.md)),

          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AlmaColors.accent(isDark),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AlmaRadius.full),
                ),
                textStyle: AlmaTypography.labelMedium(isDark, context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }
}