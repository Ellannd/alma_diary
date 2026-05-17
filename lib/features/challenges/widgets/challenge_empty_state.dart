import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
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
            size: AlmaSpacing.r(context, 80),
            color: color.withValues(alpha: .4),
          ),
          SizedBox(height: AlmaSpacing.r(context, 16)),
          Text(
            'No hay desafíos disponibles',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AlmaColors.info
                      .withValues(alpha: .6),
                ),
          ),
        ],
      ),
    );
  }
}