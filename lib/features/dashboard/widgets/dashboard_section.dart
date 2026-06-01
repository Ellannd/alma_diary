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
      padding:  EdgeInsets.only(
        bottom: AlmaSpacing.r(context, AlmaSpacing.xl), 
        left: AlmaSpacing.r(context, AlmaSpacing.xl), 
        top: AlmaSpacing.r(context, AlmaSpacing.lg), 
        right: AlmaSpacing.r(context, AlmaSpacing.xl)),
      child: child,
    );
  }
}