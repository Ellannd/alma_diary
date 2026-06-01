// lib/design_system/tokens/alma_responsive.dart
import 'package:flutter/material.dart';

class AlmaResponsive {
  AlmaResponsive._();

  // Breakpoints de referencia
  static const double _baseWidth = 390.0; // iPhone 14 Pro
//static const double _minWidth = 320.0;  // SE / compactos
// static const double _maxWidth = 430.0;  // Plus / grandes

  // Factor de escala general (0.85 – 1.0)
  static double scale(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return (w / _baseWidth).clamp(0.85, 1.0);
  }

  // Factor solo para tipografía (más conservador)
  static double textScale(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return (w / _baseWidth).clamp(0.88, 1.0);
  }

  // Ancho de pantalla útil
  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  // Shortcuts
  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 360;

  static bool isSmall(BuildContext context) =>
      MediaQuery.sizeOf(context).width < _baseWidth;
}