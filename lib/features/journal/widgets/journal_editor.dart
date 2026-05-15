import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class JournalEditor extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool enabled;
  final String? hintText;
  final ValueChanged<String>? onChanged;

  const JournalEditor({
    super.key,
    required this.controller,
    this.focusNode,
    this.enabled = true,
    this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: AlmaSpacing.r(context, AlmaSpacing.cardVGap),
          ),
          child: Text(
            'La única salida es a través de ello.',
            textAlign: TextAlign.center,
            style: AlmaTypography.journal(isDark, context),
          ),
        ),

        ClipRRect(
          borderRadius: BorderRadius.circular(AlmaRadius.xl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(
                AlmaSpacing.r(context, AlmaSpacing.lg),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AlmaRadius.xl),
                color: AlmaColors.surface(isDark).withValues(alpha: .72),
                border: Border.all(
                  color: AlmaColors.border(isDark),
                ),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: AlmaSpacing.r(context, 300),
                  maxHeight: AlmaSpacing.r(context, 420),
                ),
                child: SingleChildScrollView(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    enabled: enabled,
                    onChanged: onChanged,
                    maxLines: null,
                    cursorColor: AlmaColors.textPrimary(isDark),
                    style: AlmaTypography.bodyMedium(isDark),
                    decoration: InputDecoration(
                      isDense: true,
                      fillColor: AlmaColors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hoverColor: AlmaColors.transparent,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      hintText: hintText ?? 'Escribe tus pensamientos.',
                      hintStyle: AlmaTypography.bodyLarge(isDark).copyWith(
                        color: AlmaColors.textMuted(isDark),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
