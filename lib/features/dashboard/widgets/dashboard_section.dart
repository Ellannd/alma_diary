import 'package:flutter/material.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';

class DashboardSection extends StatelessWidget {
  final Widget child;
  final Widget? trailing;

  const DashboardSection({
    super.key,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AlmaSpacing.xxl, left: AlmaSpacing.xxl, top: AlmaSpacing.xl, right: AlmaSpacing.xxl),
      child: child,
    );
  }
}