import 'package:flutter/material.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';

enum AuthInputValidation { none, valid, invalid }

class AuthInput extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final AuthInputValidation validation;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;

  const AuthInput({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.validation = AuthInputValidation.none,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.onEditingComplete,
  });

  @override
  State<AuthInput> createState() => _AuthInputState();
}

class _AuthInputState extends State<AuthInput> {
  bool _hasText = false;
  bool _obscured = true; // estado interno del ojo

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscure;
    widget.controller.addListener(() {
      setState(() => _hasText = widget.controller.text.isNotEmpty);
    });
  }

  Color _borderColor(bool isDark) {
    return switch (widget.validation) {
      AuthInputValidation.valid   => Colors.green.shade400,
      AuthInputValidation.invalid => Colors.redAccent,
      AuthInputValidation.none    => AlmaColors.border(isDark).withValues(alpha: .08),
    };
  }

  Widget? _suffixIcon(bool isDark) {
    // Campo contraseña — ojo siempre visible
    if (widget.obscure) {
      return IconButton(
        icon: Icon(
          _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 18,
          color: AlmaColors.textMuted(isDark),
        ),
        onPressed: () => setState(() => _obscured = !_obscured),
      );
    }

    // Campo normal — check/error según validación
    if (!_hasText) return null;
    return switch (widget.validation) {
      AuthInputValidation.valid   => Icon(Icons.check, color: Colors.green.shade400, size: 18),
      AuthInputValidation.invalid => Icon(Icons.close, color: Colors.redAccent, size: 18),
      AuthInputValidation.none    => Icon(Icons.check, color: AlmaColors.textPrimary(isDark), size: 18),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: widget.controller,
      obscureText: widget.obscure ? _obscured : false,
      cursorColor: AlmaColors.textPrimary(isDark),
      style: AlmaTypography.bodyLarge(isDark, context),
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onEditingComplete: widget.onEditingComplete,
      decoration: InputDecoration(
        labelText: widget.hint,
        errorText: widget.errorText,
        labelStyle: AlmaTypography.bodyMedium(isDark, context).copyWith(
          color: AlmaColors.textPrimary(isDark).withValues(alpha: .5),
        ),
        filled: true,
        fillColor: AlmaColors.glass(isDark).withValues(alpha: .2),
        suffixIcon: _suffixIcon(isDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AlmaRadius.input),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AlmaRadius.input),
          borderSide: BorderSide(color: _borderColor(isDark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AlmaRadius.input),
          borderSide: BorderSide(
            color: widget.validation == AuthInputValidation.invalid
                ? Colors.redAccent
                : AlmaColors.textPrimary(isDark),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AlmaRadius.input),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}