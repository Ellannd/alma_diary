import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
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
      padding: EdgeInsets.all(AlmaSpacing.r(context,22)),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),

        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AlmaColors.info.withValues(alpha: 0.10),
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
                size: AlmaSpacing.r(context,22),
              ),

               SizedBox(width: AlmaSpacing.r(context,10)),

              Text(
                'Narrativa de evolución',
                style: TextStyle(
                  fontSize: AlmaSpacing.r(context,16),
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
            ],
          ),

          SizedBox(height: AlmaSpacing.r(context,18)),

          Text(
            narrative,
            style: TextStyle(
              fontSize: AlmaSpacing.r(context,16),
              height: 1.7,
              color: onSurface.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}