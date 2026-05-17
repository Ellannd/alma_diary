import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:flutter/material.dart';

class ChallengeProgressBar extends StatelessWidget {
  final int progress;
  final bool isCompleted;

  const ChallengeProgressBar({
    super.key,
    required this.progress,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress / 100,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: .12),
            valueColor: AlwaysStoppedAnimation(AlmaColors.textPrimary(Theme.of(context).brightness == Brightness.dark)),
          ),
        ),
        SizedBox(height: AlmaSpacing.r(context, 6)),
        Text(
          isCompleted ? 'Completado' : 'Progreso: $progress%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color.withValues(alpha: .8),
              ),
        ),
      ],
    );
  }
}