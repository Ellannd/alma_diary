import 'package:flutter/material.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';

class AlmaTheme {
  AlmaTheme._();

  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: AlmaColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AlmaColors.lightAccent,
        secondary: AlmaColors.lightAccent,
        surface: AlmaColors.lightSurface,
        error: AlmaColors.error,
      ),
      textTheme: _textTheme(false),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AlmaColors.lightBackground,
        foregroundColor: AlmaColors.lightTextPrimary,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        color: AlmaColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AlmaRadius.card),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AlmaColors.lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AlmaRadius.input),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(14),
      ),
      dividerColor: AlmaColors.lightBorder,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AlmaColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AlmaColors.darkAccent,
        secondary: AlmaColors.darkAccent,
        surface: AlmaColors.darkSurface,
        error: AlmaColors.error,
      ),
      textTheme: _textTheme(true),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AlmaColors.darkBackground,
        foregroundColor: AlmaColors.darkTextPrimary,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        color: AlmaColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AlmaRadius.card),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AlmaColors.darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AlmaRadius.input),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(14),
      ),
      dividerColor: AlmaColors.darkBorder,
    );
  }

  static TextTheme _textTheme(bool isDark) {
    return TextTheme(
      displayLarge: AlmaTypography.displayLarge(isDark),
      displayMedium: AlmaTypography.displayMedium(isDark),
      headlineLarge: AlmaTypography.h1(isDark),
      headlineMedium: AlmaTypography.h2(isDark),
      headlineSmall: AlmaTypography.h3(isDark),
      bodyLarge: AlmaTypography.bodyLarge(isDark),
      bodyMedium: AlmaTypography.bodyMedium(isDark),
      bodySmall: AlmaTypography.bodySmall(isDark),
      labelLarge: AlmaTypography.labelLarge(isDark),
      labelMedium: AlmaTypography.labelMedium(isDark),
      labelSmall: AlmaTypography.labelSmall(isDark),
    );
  }
}
