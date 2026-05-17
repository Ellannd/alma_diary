// lib/design_system/tokens/alma_typography.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'alma_colors.dart';
import 'alma_responsive.dart';

class AlmaTypography {
  AlmaTypography._();

  static TextStyle _base({
    required bool isDark,
    required double size,
    required FontWeight weight,
    double height = 1.2,
    Color? color,
    double letterSpacing = 0.0,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color ?? AlmaColors.textPrimary(isDark),
    );
  }

  static TextStyle _secondary({
    required bool isDark,
    required double size,
    required FontWeight weight,
    double height = 1.2,
    Color? color,
    double letterSpacing = 0.0,
  }) {
    return GoogleFonts.manrope(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color ?? AlmaColors.textPrimary(isDark),
    );
  }

  static TextStyle _logo({
    required bool isDark,
    required double size,
    required FontWeight weight,
    double height = 1.2,
    Color? color,
    double letterSpacing = 0.0,
  }) {
    return GoogleFonts.roboto(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color ?? AlmaColors.textPrimary(isDark),
    );
  }

  // Helper interno para escalar con contexto
  static double _s(BuildContext context, double size) =>
      size * AlmaResponsive.textScale(context);

  // =========================
  // DISPLAY — con contexto
  // =========================
  static TextStyle dashboardGreetingLight(bool isDark, BuildContext context) =>
      _base(
        isDark: isDark,
        size: _s(context, 46),
        weight: FontWeight.w200,
        height: 1.1,
        letterSpacing: -0.5,
      );

  static TextStyle dashboardGreetingDark(bool isDark, BuildContext context) =>
      _base(
        isDark: isDark,
        size: _s(context, 46),
        weight: FontWeight.w500,
        height: 1.1,
        letterSpacing: -0.5,
      );

    static TextStyle journal(bool isDark, BuildContext context) =>
      _base(
        isDark: isDark,
        size: _s(context, 30),
        weight: FontWeight.w500,
        height: 1.1,
        letterSpacing: -0.5,
      );    

  static TextStyle dashboardSecondary(bool isDark, [BuildContext? context]) =>
      _secondary(
        isDark: isDark,
        size: context != null ? _s(context, 16) : 16,
        weight: FontWeight.w400,
        height: 1.1,
        letterSpacing: -0.5,
      );

  static TextStyle logoHeader(bool isDark, [BuildContext? context]) => _logo(
        isDark: isDark,
        size: context != null ? _s(context, 40) : 40,
        weight: FontWeight.w100,
        height: 1.1,
        letterSpacing: 0,
      );

  static TextStyle displayLarge(bool isDark, [BuildContext? context]) => _base(
        isDark: isDark,
        size: context != null ? _s(context, 34) : 34,
        weight: FontWeight.w600,
        height: 1.1,
        letterSpacing: -0.5,
      );

  static TextStyle displayMedium(bool isDark, [BuildContext? context]) =>
      _base(
        isDark: isDark,
        size: context != null ? _s(context, 28) : 28,
        weight: FontWeight.w600,
        height: 1.15,
        letterSpacing: -0.3,
      );

  // =========================
  // HEADINGS — con contexto opcional
  // =========================
  static TextStyle h1(bool isDark, [BuildContext? context]) => _base(
        isDark: isDark,
        size: context != null ? _s(context, 24) : 24,
        weight: FontWeight.w600,
      );

  static TextStyle h2(bool isDark, [BuildContext? context]) => _base(
        isDark: isDark,
        size: context != null ? _s(context, 20) : 20,
        weight: FontWeight.w600,
      );

  static TextStyle h3(bool isDark, [BuildContext? context]) => _secondary(
        isDark: isDark,
        size: context != null ? _s(context, 18) : 18,
        weight: FontWeight.w600,
      );

  // =========================
  // BODY
  // =========================
  static TextStyle bodyLarge(bool isDark, [BuildContext? context]) => _base(
        isDark: isDark,
        size: context != null ? _s(context, 16) : 16,
        weight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle bodyMedium(bool isDark, [BuildContext? context]) => _base(
        isDark: isDark,
        size: context != null ? _s(context, 14) : 14,
        weight: FontWeight.w400,
        height: 1.45,
      );

  static TextStyle bodySmall(bool isDark, [BuildContext? context]) => _base(
        isDark: isDark,
        size: context != null ? _s(context, 12) : 12,
        weight: FontWeight.w400,
        height: 1.4,
      );

  // =========================
  // LABELS
  // =========================
  static TextStyle labelLarge(bool isDark, [BuildContext? context]) => _base(
        isDark: isDark,
        size: context != null ? _s(context, 14) : 14,
        weight: FontWeight.w500,
        letterSpacing: 0.1,
      );

  static TextStyle labelMedium(bool isDark, [BuildContext? context]) => _base(
        isDark: isDark,
        size: context != null ? _s(context, 12) : 12,
        weight: FontWeight.w500,
        letterSpacing: 0.1,
      );

  static TextStyle labelSmall(bool isDark, [BuildContext? context]) => _base(
        isDark: isDark,
        size: context != null ? _s(context, 11) : 11,
        weight: FontWeight.w500,
        letterSpacing: 0.2,
      );

  // =========================
  // SPECIAL
  // =========================
  static TextStyle emotion(bool isDark) => _base(
        isDark: isDark,
        size: 13,
        weight: FontWeight.w500,
        letterSpacing: 0.2,
        color: AlmaColors.emotionNeutral,
      );

  static TextStyle quote(bool isDark, [BuildContext? context]) => _base(
        isDark: isDark,
        size: context != null ? _s(context, 15) : 15,
        weight: FontWeight.w400,
        height: 1.6,
        letterSpacing: 0.1,
      );

  static TextStyle button(bool isDark, [BuildContext? context]) => _base(
        isDark: isDark,
        size: context != null ? _s(context, 14) : 14,
        weight: FontWeight.w600,
        letterSpacing: 0.2,
      );

  // =========================
  // DISPLAY SIN CONTEXTO — legacy, no usar en widgets nuevos
  // =========================
  static TextStyle displaySmall(bool isDark) => _base(
        isDark: isDark,
        size: 22,
        weight: FontWeight.w600,
        height: 1.1,
        letterSpacing: -0.3,
      );
}