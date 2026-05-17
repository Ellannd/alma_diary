import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';
import 'package:flutter/material.dart';
import 'challenge_progress_bar.dart';
import 'challenge_action_strip.dart';

class ChallengeCard extends StatelessWidget {
  final String title;
  final String description;
  final int difficulty;
  final String category;
  final int progress;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback? onStart;
  final Function(int)? onUpdateProgress;

  const ChallengeCard({
    super.key,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.category,
    required this.progress,
    required this.isActive,
    required this.isCompleted,
    this.onStart,
    this.onUpdateProgress,
  });

  IconData _icon() {
    switch (category.toLowerCase()) {
      case 'valentía':
        return Icons.shield_rounded;
      case 'disciplina':
        return Icons.fitness_center;
      case 'mindfulness':
        return Icons.self_improvement;
      case 'emocional':
        return Icons.favorite_rounded;
      default:
        return Icons.auto_awesome;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = AlmaColors.textPrimary(isDark);

    return Container(
      margin:  EdgeInsets.only(bottom: AlmaSpacing.r(context, 16)),
      padding: EdgeInsets.all(AlmaSpacing.r(context, AlmaSpacing.lg-2)),
      decoration: BoxDecoration(
        color: AlmaColors.background(isDark),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withValues(alpha: 0.80),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================
          // HEADER
          // ======================
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withValues(alpha: 0.2),
                child: Icon(_icon(), color: color, size: 20),
              ),
              SizedBox(width: AlmaSpacing.r(context, 10)),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: color.withValues(alpha: 0.8),
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // dificultad
              Row(
                children: List.generate(
                  difficulty.clamp(1, 10),
                  (i) => const Icon(
                    Icons.star,
                    size: 14,
                    color: AlmaColors.warning,
                  ),
                ),
              ),
            ],
          ),
 
          SizedBox(height: AlmaSpacing.r(context, 12)),

          // ======================
          // DESCRIPTION
          // ======================
          Text(
            description,
            style: theme.textTheme.bodyMedium,
          ),

          SizedBox(height: AlmaSpacing.r(context, 14)),

          // ======================
          // PROGRESS
          // ======================
          if (isActive || isCompleted)
            ChallengeProgressBar(
              progress: progress,
              isCompleted: isCompleted,
            ),

          SizedBox(height: AlmaSpacing.r(context, 12)),

          // ======================
          // ACTIONS
          // ======================

          if (!isActive && !isCompleted && onStart != null)
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: AlmaColors.background(isDark),
                  textStyle: AlmaTypography.labelSmall(isDark).copyWith(color: AlmaColors.textPrimary(isDark)),
                  padding: EdgeInsets.symmetric(
                    horizontal: AlmaSpacing.r(context, 18),
                    vertical: AlmaSpacing.r(context, 10),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Iniciar desafío'),
              ),
            ),

          if (isActive && !isCompleted && onUpdateProgress != null)
            ChallengeActionStrip(
              progress: progress,
              onUpdateProgress: onUpdateProgress,
            ),
        ],
      ),
    );
  }
}