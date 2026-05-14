import 'package:flutter/material.dart';
import "package:google_fonts/google_fonts.dart";
import 'alma_colors.dart';

class AlmaTypography {
  AlmaTypography._();

  // =========================
  // BASE TEXT STYLES BUILDER
  // =========================
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

  // =========================
  // DISPLAY
  // =========================

   static TextStyle dashboardGreetingLigtht(bool isDark) => _base(
        isDark: isDark,
        size: 46,
        weight: FontWeight.w200,
        height: 1.1,
        letterSpacing: -0.5,
      );

       static TextStyle logoHeader(bool isDark) => _logo(
        isDark: isDark,
        size: 40,
        weight: FontWeight.w100,
        height: 1.1,
        letterSpacing: 0,
      );

   static TextStyle dashboardGreetingDark(bool isDark) => _base(
        isDark: isDark,
        size: 46,
        weight: FontWeight.w500,
        height: 1.1,
        letterSpacing: -0.5,
      );
  
     static TextStyle dashboardSecondary(bool isDark) => _secondary(
        isDark: isDark,
        size: 16,
        weight: FontWeight.w400,
        height: 1.1,
        letterSpacing: -0.5,
      );
  

  static TextStyle displayLarge(bool isDark) => _base(
        isDark: isDark,
        size: 34,
        weight: FontWeight.w600,
        height: 1.1,
        letterSpacing: -0.5,
      );

  static TextStyle displayMedium(bool isDark) => _base(
        isDark: isDark,
        size: 28,
        weight: FontWeight.w600,
        height: 1.15,
        letterSpacing: -0.3,
      );

  // =========================
  // HEADINGS
  // =========================
  static TextStyle h1(bool isDark) => _base(
        isDark: isDark,
        size: 24,
        weight: FontWeight.w600,
      );

  static TextStyle h2(bool isDark) => _base(
        isDark: isDark,
        size: 20,
        weight: FontWeight.w600,
      );

  static TextStyle h3(bool isDark) => _base(
        isDark: isDark,
        size: 18,
        weight: FontWeight.w600,
      );

  // =========================
  // BODY
  // =========================
  static TextStyle bodyLarge(bool isDark) => _base(
        isDark: isDark,
        size: 16,
        weight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle bodyMedium(bool isDark) => _base(
        isDark: isDark,
        size: 14,
        weight: FontWeight.w400,
        height: 1.45,
      );

  static TextStyle bodySmall(bool isDark) => _base(
        isDark: isDark,
        size: 12,
        weight: FontWeight.w400,
        height: 1.4,
      );

  // =========================
  // LABELS
  // =========================
  static TextStyle labelLarge(bool isDark) => _base(
        isDark: isDark,
        size: 14,
        weight: FontWeight.w500,
        letterSpacing: 0.1,
      );

  static TextStyle labelMedium(bool isDark) => _base(
        isDark: isDark,
        size: 12,
        weight: FontWeight.w500,
        letterSpacing: 0.1,
      );

  static TextStyle labelSmall(bool isDark) => _base(
        isDark: isDark,
        size: 11,
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

  static TextStyle quote(bool isDark) => _base(
        isDark: isDark,
        size: 15,
        weight: FontWeight.w400,
        height: 1.6,
        letterSpacing: 0.1,
      );

  static TextStyle button(bool isDark) => _base(
        isDark: isDark,
        size: 14,
        weight: FontWeight.w600,
        letterSpacing: 0.2,
      );
}