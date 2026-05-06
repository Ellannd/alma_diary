import 'package:flutter/material.dart';

class AlmaInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final int maxLines;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool autofocus;

  const AlmaInput({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.onChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    this.borderRadius = 14,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark
        ? Colors.white.withValues(alpha: .04)
        : Colors.black.withValues(alpha: .03);

    final borderColor = isDark
        ? Colors.white.withValues(alpha: .08)
        : Colors.black.withValues(alpha: .08);

    final focusColor = theme.colorScheme.primary.withValues(alpha: .4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              labelText!,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        Focus(
          child: Builder(
            builder: (context) {
              final hasFocus = Focus.of(context).hasFocus;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: hasFocus ? focusColor : borderColor,
                  ),
                ),
                padding: padding,
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  maxLines: obscureText ? 1 : maxLines,
                  keyboardType: keyboardType,
                  autofocus: autofocus,
                  onChanged: onChanged,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: hintText,
                    border: InputBorder.none,
                    prefixIcon: prefixIcon,
                    suffixIcon: suffixIcon,
                  ),
                ),
              );
            },
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.redAccent,
            ),
          ),
        ],
      ],
    );
  }
}