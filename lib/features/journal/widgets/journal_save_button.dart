import 'package:flutter/material.dart';

import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class JournalSaveButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;

  const JournalSaveButton({
    super.key,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final primary =
        Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          foregroundColor:
              Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AlmaRadius.full,
            ),
          ),
        ),
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimary,
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AlmaSpacing.md,
                ),
                child: Text(
                  'Guardar entrada',
                  style: AlmaTypography.labelLarge(
                    isDark,
                  ).copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
      ),
    );
  }
}