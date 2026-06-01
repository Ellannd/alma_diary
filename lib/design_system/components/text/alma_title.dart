import 'package:flutter/material.dart';
import 'alma_text.dart';

class AlmaTitle extends StatelessWidget {
  final String text;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment alignment;

  const AlmaTitle({
    super.key,
    required this.text,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: alignment,
              children: [
                AlmaText(
                  text,
                  variant: AlmaTextVariant.h2,
                  weight: FontWeight.w600,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  AlmaText(
                    subtitle!,
                    variant: AlmaTextVariant.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
