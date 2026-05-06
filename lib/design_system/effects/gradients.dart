import 'package:flutter/material.dart';

class AlmaGradients {
  AlmaGradients._();

  /// Subtle background gradient (Endel-style ambient)
  static LinearGradient background(bool isDark) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              const Color(0xFF0B0F14),
              const Color(0xFF121824),
              const Color(0xFF0B0F14),
            ]
          : [
              const Color(0xFFF7F7FB),
              const Color(0xFFEDEFF5),
              const Color(0xFFF7F7FB),
            ],
    );
  }

  /// Accent gradient (used for highlights / CTA / glow)
  static LinearGradient accent(Color primary) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        primary.withValues(alpha: 0.9),
        primary.withValues(alpha: 0.6),
      ],
    );
  }

  /// Glass overlay gradient (very subtle, to add depth)
  static LinearGradient glassOverlay(bool isDark) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? [
              Colors.white.withValues(alpha: 0.06),
              Colors.white.withValues(alpha: 0.02),
            ]
          : [
              Colors.white.withValues(alpha: 0.7),
              Colors.white.withValues(alpha: 0.4),
            ],
    );
  }

  /// Divider / subtle separation gradient
  static LinearGradient divider(bool isDark) {
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: isDark
          ? [
              Colors.transparent,
              Colors.white.withValues(alpha: 0.08),
              Colors.transparent,
            ]
          : [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.08),
              Colors.transparent,
            ],
    );
  }
}