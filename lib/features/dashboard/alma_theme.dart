import 'package:flutter/material.dart';

class AlmaTheme {
  //  BASE COLORS
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);

  static const Color backgroundLight = Color(0xFFF7F7FB);
  static const Color cardLight = Colors.white;

  static const Color primary = Color(0xFF7C3AED);
  static const Color accent = Color(0xFF7C3AED);
  static const Color accent2 = Color(0xFF6366F1);

  static const Color textDark = Colors.white;
  static const Color textLight = Color(0xFF1A1A1A);

  static const Color lineArt = Color(0xFFF5E9DA);

  //  DARK THEME
  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    cardColor: cardDark,

    colorScheme: const ColorScheme.dark(
      primary: accent,
      secondary: accent2,
      surface: cardDark,
      onPrimary: textDark,
      onSecondary: textDark,
      onSurface: textDark,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textDark, fontFamily: 'Sans'),
      bodyMedium: TextStyle(color: textDark, fontFamily: 'Sans'),
      titleLarge: TextStyle(
        color: textDark,
        fontWeight: FontWeight.bold,
        fontFamily: 'Sans',
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: cardDark,
      foregroundColor: textDark,
      elevation: 0,
    ),

    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: cardDark,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: accent2),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: accent),
      ),
      hintStyle: TextStyle(color: Colors.white54),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: textDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardDark,
      selectedItemColor: accent,
      unselectedItemColor: Colors.white54,
      showUnselectedLabels: true,
    ),
  );

  // LIGHT THEME
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundLight,
    cardColor: cardLight,

    colorScheme: const ColorScheme.light(
      primary: accent,
      secondary: accent2,
      surface: cardLight,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textLight,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textLight, fontFamily: 'Sans'),
      bodyMedium: TextStyle(color: textLight, fontFamily: 'Sans'),
      titleLarge: TextStyle(
        color: textLight,
        fontWeight: FontWeight.bold,
        fontFamily: 'Sans',
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: cardLight,
      foregroundColor: textLight,
      elevation: 0,
    ),

    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: cardLight,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: accent),
      ),
      hintStyle: TextStyle(color: Colors.black38),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardLight,
      selectedItemColor: accent,
      unselectedItemColor: Colors.black45,
      showUnselectedLabels: true,
    ),
  );
}