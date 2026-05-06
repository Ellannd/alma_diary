import 'package:flutter/material.dart';
import '../components/text/alma_title.dart';

class AlmaSection extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final double spacing;

  const AlmaSection({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            AlmaTitle(
              text: title!,
              subtitle: subtitle,
              trailing: trailing,
            ),
            SizedBox(height: spacing),
          ],
          child,
        ],
      ),
    );
  }
}