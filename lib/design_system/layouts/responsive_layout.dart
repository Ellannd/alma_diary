import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= desktopBreakpoint && desktop != null) {
      return desktop!;
    }

    if (width >= tabletBreakpoint && tablet != null) {
      return tablet!;
    }

    return mobile;
  }
}