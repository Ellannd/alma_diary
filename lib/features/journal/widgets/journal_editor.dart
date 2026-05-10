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
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final primary =
        Theme.of(context).colorScheme.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(
        AlmaRadius.xl,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          padding: const EdgeInsets.all(
            AlmaSpacing.lg,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AlmaRadius.xl,
            ),
            color: AlmaColors.surface(isDark)
                .withValues(alpha: .72),
            border: Border.all(
              color: AlmaColors.border(isDark),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primary.withValues(alpha: .10),
                AlmaColors.transparent,
              ],
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            onChanged: onChanged,
            minLines: 14,
            maxLines: null,
            cursorColor: primary,
            style: AlmaTypography.bodyLarge(isDark),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText:
                  hintText ?? 'Escribe lo que sientes...',
              hintStyle:
                  AlmaTypography.bodyLarge(isDark)
                      .copyWith(
                color: AlmaColors.textMuted(isDark),
              ),
            ),
          ),
        ),
      ),
    );
  }
}