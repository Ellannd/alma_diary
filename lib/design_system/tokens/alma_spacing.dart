// lib/design_system/tokens/alma_spacing.dart
import 'package:flutter/material.dart';
import 'alma_responsive.dart';

class AlmaSpacing {
  AlmaSpacing._();

  // Base scale (8pt system) — constantes para uso sin contexto
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
  static const double xxxl = 56.0;

  static const double screenPadding = 20.0;
  static const double sectionGap = 28.0;
  static const double cardPadding = 16.0;
  static const double buttonPadding = 14.0;
  static const double listItemGap = 12.0;
  static const double formFieldGap = 14.0;
  static const double iconGap = 8.0;
  static const double minTouchTarget = 44.0;

  // Dashboard specific — constantes legacy
  static const double edgeMargin = 40.0;
  static const double section = 32.0;
  static const double gridGap = 32.0;
  static const double cardVGap = 56.0;
  static const double iconLarge = 56.0;

  // =========================
  // RESPONSIVOS — requieren contexto
  // =========================
  static double r(BuildContext context, double value) =>
      value * AlmaResponsive.scale(context);

  static double screenH(BuildContext context) =>
      AlmaResponsive.isCompact(context) ? 16.0 : 20.0;

  static double gridGapR(BuildContext context) =>
      AlmaResponsive.isCompact(context) ? 12.0 : 16.0;

  static double vGap(BuildContext context) =>
      AlmaResponsive.isCompact(context) ? 24.0 : 32.0;

  static double sectionR(BuildContext context) =>
      AlmaResponsive.isCompact(context) ? 20.0 : 28.0;

  static double cardPaddingR(BuildContext context) =>
      AlmaResponsive.isCompact(context) ? 14.0 : 18.0;

  static double navbarBottomR(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return bottom > 0 ? bottom + 12 : 16.0;
  }
}