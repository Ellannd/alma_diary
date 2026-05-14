import 'package:flutter/material.dart';
import "package:responsive_framework/responsive_framework.dart";

extension ResponsiveContext on BuildContext {

  // =========================
  // MEDIA QUERY
  // =========================

  MediaQueryData get mediaQuery =>
      MediaQuery.of(this);

  Size get screenSize =>
      mediaQuery.size;

  double get screenWidth =>
      screenSize.width;

  double get screenHeight =>
      screenSize.height;

  double get pixelRatio =>
      mediaQuery.devicePixelRatio;

  double get textScale =>
      mediaQuery.textScaler.scale(1);

  Orientation get orientation =>
      mediaQuery.orientation;

  bool get isPortrait =>
      orientation == Orientation.portrait;

  bool get isLandscape =>
      orientation == Orientation.landscape;

  // =========================
  // SAFE AREA
  // =========================

  EdgeInsets get viewPadding =>
      mediaQuery.viewPadding;

  EdgeInsets get viewInsets =>
      mediaQuery.viewInsets;

  double get topInset =>
      viewPadding.top;

  double get bottomInset =>
      viewPadding.bottom;

  bool get keyboardVisible =>
      viewInsets.bottom > 0;

  // =========================
  // BREAKPOINTS
  // =========================

  bool get isSmallPhone =>
      screenWidth < 360;

  bool get isPhone =>
      ResponsiveBreakpoints.of(this).isPhone;

  bool get isTablet =>
      ResponsiveBreakpoints.of(this).isTablet;

  bool get isDesktop =>
      ResponsiveBreakpoints.of(this).isDesktop;

  // =========================
  // RESPONSIVE SPACING
  // =========================

  double get responsiveHorizontalPadding {
    if (isSmallPhone) return 12;
    if (isPhone) return 16;
    if (isTablet) return 24;
    return 32;
  }

  double get responsiveVerticalPadding {
    if (isSmallPhone) return 12;
    if (isPhone) return 16;
    if (isTablet) return 20;
    return 24;
  }

  EdgeInsets get screenPadding =>
      EdgeInsets.symmetric(
        horizontal: responsiveHorizontalPadding,
        vertical: responsiveVerticalPadding,
      );

  // =========================
  // RESPONSIVE VALUES
  // =========================

  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) {
      return desktop;
    }

    if (isTablet && tablet != null) {
      return tablet;
    }

    return mobile;
  }

  double wp(double percent) =>
      screenWidth * percent;

  double hp(double percent) =>
      screenHeight * percent;

  // =========================
  // RESPONSIVE FONT SCALE
  // =========================

  double responsiveFont(double size) {
    final scale = screenWidth / 375;

    final responsiveSize = size * scale;

    return responsiveSize.clamp(
      size * 0.85,
      size * 1.25,
    );
  }
}