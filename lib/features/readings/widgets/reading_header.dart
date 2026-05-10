import 'package:flutter/material.dart';

class ReadingHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const ReadingHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: onSurface,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}