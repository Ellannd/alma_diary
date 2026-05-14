// dashboard_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class DashboardHeader extends StatelessWidget {
  final VoidCallback? onSettingsTap;

  const DashboardHeader({
    super.key,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // =========================
        // LOGO + APP NAME 
        // =========================
        //todo make responsive
        SvgPicture.asset(
          'logo/logo.svg',
          width: 65,
          height: 65,
    
        ),

        const SizedBox(width: 10),

        Text(
          'Alma',
          style: AlmaTypography.logoHeader(isDark).copyWith(
            letterSpacing: -0.5,
          ),
        ),

        const Spacer(),

        // =========================
        // SETTINGS
        // =========================
        GestureDetector(
          onTap: onSettingsTap,
          child: SvgPicture.asset(
            'icon/settings.svg',
            width: 28,
            height: 28,
            colorFilter: ColorFilter.mode(
              AlmaColors.textMuted(isDark),
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }
}