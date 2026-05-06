import 'package:flutter/material.dart';

class AlmaLoading extends StatelessWidget {
  final String? text;
  final double size;
  final bool centered;

  const AlmaLoading({
    super.key,
    this.text,
    this.size = 20,
    this.centered = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final loader = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.primary,
          ),
        ),
        if (text != null) ...[
          const SizedBox(height: 12),
          Text(
            text!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: .7),
            ),
          ),
        ],
      ],
    );

    if (!centered) return loader;

    return Center(child: loader);
  }
}