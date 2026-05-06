import 'package:flutter/material.dart';

class AlmaScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigation;
  final Widget? floatingActionButton;
  final bool safeArea;
  final EdgeInsetsGeometry padding;
  final bool extendBody;
  final bool resizeToAvoidBottomInset;

  const AlmaScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.bottomNavigation,
    this.floatingActionButton,
    this.safeArea = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.extendBody = false,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget content = Padding(
      padding: padding,
      child: child,
    );

    if (safeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      appBar: appBar,
      extendBody: extendBody,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: content,
      bottomNavigationBar: bottomNavigation,
      floatingActionButton: floatingActionButton,
    );
  }
}