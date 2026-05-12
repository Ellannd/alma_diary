import 'package:flutter/material.dart';
import "package:alma_diary/design_system/tokens/alma_colors.dart";

enum AlmaButtonVariant { primary, secondary, ghost, danger }

class AlmaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AlmaButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double height;
  final double borderRadius;

  const AlmaButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AlmaButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.height = 48,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDisabled = onPressed == null || isLoading;

    final colors = _resolveColors(theme);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ButtonStyle(
          elevation: WidgetStateProperty.all(0),
          backgroundColor: WidgetStateProperty.all(colors.background),
          foregroundColor: WidgetStateProperty.all(colors.foreground),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: BorderSide(
                color: colors.border,
                width: 1,
              ),
            ),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? SizedBox(
                  key: const ValueKey('loading'),
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.foreground,
                  ),
                )
              : Row(
                  key: const ValueKey('content'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      text,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  _ButtonColors _resolveColors(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    switch (variant) {
      case AlmaButtonVariant.primary:
        return _ButtonColors(
          background: isDark
              ? AlmaColors.darkAccent
              : AlmaColors.darkAccentSoft,
          foreground: AlmaColors.background(isDark),
          border: Colors.transparent,
        );

      case AlmaButtonVariant.secondary:
        return _ButtonColors(
          background: isDark
              ? AlmaColors.surfaceVariant(isDark)
              : AlmaColors.surface(isDark),
          foreground: isDark ? Colors.white : Colors.black,
          border: isDark
              ? AlmaColors.border(isDark).withValues(alpha: .08)
              : AlmaColors.border(isDark).withValues(alpha: .08),
        );

      case AlmaButtonVariant.ghost:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: isDark ? Colors.white : Colors.black,
          border: Colors.transparent,
        );

      case AlmaButtonVariant.danger:
        return _ButtonColors(
          background: const Color(0xFFEF4444),
          foreground: Colors.white,
          border: Colors.transparent,
        );
    }
  }
}

class _ButtonColors {
  final Color background;
  final Color foreground;
  final Color border;

  _ButtonColors({
    required this.background,
    required this.foreground,
    required this.border,
  });
}