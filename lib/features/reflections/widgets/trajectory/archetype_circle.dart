import 'package:flutter/material.dart';

class ArchetypeCircle extends StatelessWidget {
  final String label;
  final double value;
  final VoidCallback onTap;

  const ArchetypeCircle({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,

      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primary.withValues(alpha: 0.3),
                width: 2,
              ),

              gradient: RadialGradient(
                colors: [
                  primary.withValues(alpha: 0.22),
                  primary.withValues(alpha: 0.05),
                ],
              ),
            ),

            child: Center(
              child: Text(
                '${value.round()}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: 90,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.75),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}