import 'package:flutter/material.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class ProfileThemeSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ProfileThemeSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      activeThumbColor: AlmaColors.accent(isDark),

      title: Text(
        'Modo oscuro',
        style: AlmaTypography.bodyMedium(isDark),
      ),

      subtitle: Text(
        'Personaliza la apariencia',
        style: AlmaTypography.bodySmall(isDark).copyWith(
          color: AlmaColors.textMuted(isDark),
        ),
      ),
    );
  }
}