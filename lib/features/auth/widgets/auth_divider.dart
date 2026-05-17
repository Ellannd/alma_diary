import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:flutter/material.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class AuthDivider extends StatelessWidget {
  final String? label;
  const AuthDivider({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AlmaColors.border(isDark).withValues(alpha: .70),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AlmaSpacing.r(context,12)),
          child: Text(
            label ?? 'Ingresa con',
            style: AlmaTypography.labelSmall(isDark, context).copyWith(
              color: AlmaColors.textMuted(isDark),
              fontSize: AlmaSpacing.r(context, 14),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AlmaColors.border(isDark).withValues(alpha: .70),
          ),
        ),
      ],
    );
  }
}