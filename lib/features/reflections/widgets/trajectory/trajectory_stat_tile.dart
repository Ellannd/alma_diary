import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:flutter/material.dart';

class TrajectoryStatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const TrajectoryStatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: EdgeInsets.all(AlmaSpacing.r(context,18)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: primary.withValues(alpha: 0.12),
        ),
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withValues(alpha: 0.12),
            ),
            child: Icon(
              icon,
              color: primary,
            ),
          ),

          SizedBox(width: AlmaSpacing.r(context,14)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.65),
                    fontSize: 13,
                  ),
                ),

                SizedBox(height: AlmaSpacing.r(context,4)),

                Text(
                  value,
                  style: TextStyle(
                    color: onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: AlmaSpacing.r(context,20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}