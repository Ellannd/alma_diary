import 'package:flutter/material.dart';

class TrajectoryConceptsWrap extends StatelessWidget {
  final List<String> concepts;

  const TrajectoryConceptsWrap({
    super.key,
    required this.concepts,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Wrap(
      spacing: 10,
      runSpacing: 10,

      children: concepts.map((concept) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),

            color: primary.withValues(alpha: 0.08),

            border: Border.all(
              color: primary.withValues(alpha: 0.15),
            ),
          ),

          child: Text(
            concept,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}