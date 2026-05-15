import 'package:flutter/material.dart';

import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';

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


    return Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // tus otros iconos (B, imagen, micrófono)
    Row(
      children: [
        IconButton(icon: const Icon(Icons.format_bold), onPressed: () {}),
        IconButton(icon: const Icon(Icons.image_outlined), onPressed: () {}),
        IconButton(icon: const Icon(Icons.mic_outlined), onPressed: () {}),
      ],
    ),

    // botón guardar a la derecha
    SizedBox(
      width: AlmaSpacing.r(context, 58),
      height: AlmaSpacing.r(context, 58),
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AlmaColors.info,
          foregroundColor: AlmaColors.info,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AlmaRadius.md),
          ),
        ),
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AlmaColors.info,
                ),
              )
            : Icon(Icons.edit_rounded, size: AlmaSpacing.r(context, 32), color: AlmaColors.lightBackground,
      ),
    ),
    )
    ]
    
);

  }
}