import 'package:flutter/material.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';


class ProfileLogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const ProfileLogoutButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AlmaColors.emotionIntense.withValues(alpha: 0.85),
          padding: EdgeInsets.symmetric(vertical: AlmaSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AlmaRadius.md),
          ),
        ),
        child: const Text('Cerrar sesión'),
      ),
    );
  }
}