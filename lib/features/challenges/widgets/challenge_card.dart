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
    final color = Theme.of(context).colorScheme.primary;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 18,
            ),
        ],
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
              const SizedBox(width: 10),

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
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ======================
          // DESCRIPTION
          // ======================
          Text(
            description,
            style: theme.textTheme.bodyMedium,
          ),

          const SizedBox(height: 14),

          // ======================
          // PROGRESS
          // ======================
          if (isActive || isCompleted)
            ChallengeProgressBar(
              progress: progress,
              isCompleted: isCompleted,
            ),

          const SizedBox(height: 12),

          // ======================
          // ACTIONS
          // ======================

          if (!isActive && !isCompleted && onStart != null)
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
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