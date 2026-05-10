import 'package:flutter/material.dart';

class TrajectoryNarrativeCard extends StatelessWidget {
  final String narrative;

  const TrajectoryNarrativeCard({
    super.key,
    required this.narrative,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),

        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withValues(alpha: 0.10),
            Theme.of(context).cardColor,
          ],
        ),

        border: Border.all(
          color: primary.withValues(alpha: 0.10),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_stories,
                color: primary,
                size: 22,
              ),

              const SizedBox(width: 10),

              Text(
                'Narrativa de evolución',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            narrative,
            style: TextStyle(
              fontSize: 16,
              height: 1.7,
              color: onSurface.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}