import 'package:flutter/material.dart';

class ChallengeEmptyState extends StatelessWidget {
  const ChallengeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: color.withValues(alpha: .4),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay desafíos disponibles',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: .6),
                ),
          ),
        ],
      ),
    );
  }
}