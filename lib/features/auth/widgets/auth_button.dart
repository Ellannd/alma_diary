import 'package:alma_diary/design_system/components/feedback/alma_loader.dart';
import 'package:flutter/material.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AlmaColors.textPrimary(isDark),
          foregroundColor: AlmaColors.darkBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AlmaRadius.button),
          ),
        ),
        child: loading
            ? SizedBox(
                height: 18,
                width: 18,
                child: AlmaLoader(
                  color: AlmaColors.background(isDark),
                ),
              )
            : Text(
                text,
                style: AlmaTypography.labelLarge(isDark, context).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AlmaColors.background(isDark),
                ),
              ),
      ),
    );
  }
}
