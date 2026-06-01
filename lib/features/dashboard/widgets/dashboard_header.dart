// dashboard_header.dart
import 'package:flutter/material.dart';

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

    return Padding(
      padding: EdgeInsets.only(right: 14.0, left: 14.0, bottom: 12.0,  top: MediaQuery.of(context).padding.top + 12), 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // =========================
          // LOGO + APP NAME 
          // =========================
          //todo make responsive
          Image.asset(
              'assets/logo/logo_1.png',
              width: 70,
              height: 70,
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
            child: Icon(Icons.settings, color: AlmaColors.textMuted(isDark), 
            size: 28,),

            ),
        ],
      ),
    );
  }
}
