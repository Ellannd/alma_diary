import 'package:flutter/material.dart';

class AlmaColors {
  // =========================
  // DARK THEME
  // =========================
  static const Color darkBackground = Color(0xFF0B0F14);
  static const Color darkSurface = Color(0xFF121824);
  static const Color darkSurfaceVariant = Color(0xFF1A2230);

  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFA7B0B8);
  static const Color darkTextMuted = Color(0xFF6C7680);

  // Accent (Spotify-inspired, customizable later via theme controller)
  static const Color darkAccent = Color(0xFF7C3AED);
  static const Color darkAccentSoft = Color(0x337C3AED);

  static const Color darkBorder = Color(0x1AFFFFFF);
  static const Color darkGlass = Color(0x0FFFFFFF);

  // =========================
  // LIGHT THEME
  // =========================
  static const Color lightBackground = Color(0xFFF7F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F3F6);

  static const Color lightTextPrimary = Color(0xFF0B0F14);
  static const Color lightTextSecondary = Color(0xFF4B5563);
  static const Color lightTextMuted = Color(0xFF9AA3AF);

  static const Color lightAccent = Color(0xFF6D28D9);
  static const Color lightAccentSoft = Color(0x336D28D9);

  static const Color lightBorder = Color(0x14000000);
  static const Color lightGlass = Color(0x0A000000);

  // =========================
  // SHARED SEMANTIC COLORS
  // =========================
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // =========================
  // TRANSPARENT
  // =========================
  static const transparent = Colors.transparent;

  // Emotional / AI system accents (for future Emotion Engine)
  static const Color emotionCalm = Color(0xFF38BDF8);
  static const Color emotionFocus = Color(0xFF6366F1);
  static const Color emotionIntense = Color(0xFFF43F5E);
  static const Color emotionNeutral = Color(0xFFA7B0B8);

  // Glassmorphism helper
  static Color glass(bool isDark) =>
      isDark ? darkGlass : lightGlass;

  static Color background(bool isDark) =>
      isDark ? darkBackground : lightBackground;

  static Color surface(bool isDark) =>
      isDark ? darkSurface : lightSurface;

  static Color surfaceVariant(bool isDark) =>
      isDark ? darkSurfaceVariant : lightSurfaceVariant;

  static Color textPrimary(bool isDark) =>
      isDark ? darkTextPrimary : lightTextPrimary;

  static Color textSecondary(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;

  static Color border(bool isDark) =>
      isDark ? darkBorder : lightBorder;

  static Color accent(bool isDark) =>
      isDark ? darkAccent : lightAccent;

  static Color accentSoft(bool isDark) =>
      isDark ? darkAccentSoft : lightAccentSoft;

  static Color textMuted(bool isDark) =>
      isDark ? darkTextMuted : lightTextMuted;
}
