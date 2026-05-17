import 'package:flutter/material.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';

class AuthInput extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;

  const AuthInput({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
  });

  @override
  State<AuthInput> createState() => _AuthInputState();
}

class _AuthInputState extends State<AuthInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() => _hasText = widget.controller.text.isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: widget.controller,
      obscureText: widget.obscure,
      cursorColor: AlmaColors.textPrimary(isDark),
      style: AlmaTypography.bodyLarge(isDark, context),
      decoration: InputDecoration(
        labelText: widget.hint,
        labelStyle: AlmaTypography.bodyMedium(isDark, context).copyWith(
          color: AlmaColors.textPrimary(isDark).withValues(alpha: .5),
        ),
        filled: true,
        fillColor: AlmaColors.glass(isDark).withValues(alpha: .2),
        suffixIcon: _hasText && !widget.obscure
            ? Icon(Icons.check, color: AlmaColors.textPrimary(isDark), size: 18)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AlmaRadius.input),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AlmaRadius.input),
          borderSide: BorderSide(
            color: AlmaColors.border(isDark).withValues(alpha: .08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AlmaRadius.input),
          borderSide: BorderSide(
            color: AlmaColors.textPrimary(isDark),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}