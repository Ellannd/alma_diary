import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:flutter/material.dart';

class ReflectionTags extends StatelessWidget {
  final String archetype;
  final String sentiment;

  const ReflectionTags({
    super.key,
    required this.archetype,
    required this.sentiment,
  });

  @override
  Widget build(BuildContext context) {
    if (archetype.isEmpty && sentiment.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        if (archetype.isNotEmpty)
          ReflectionTagChip(
            label: archetype,
            icon: Icons.psychology,
          ),

        if (sentiment.isNotEmpty)
          ReflectionTagChip(
            label: sentiment,
            icon: Icons.favorite,
          ),
      ],
    );
  }
}

class ReflectionTagChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const ReflectionTagChip({
    super.key,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AlmaSpacing.r(context, 10),
        vertical: AlmaSpacing.r(context, 6),
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AlmaSpacing.r(context, 14),
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),

          SizedBox(width: AlmaSpacing.r(context,6)),

          Text(
            label,
            style: TextStyle(
              fontSize: AlmaSpacing.r(context, 12),
              color: AlmaColors.textPrimary(Theme.of(context).brightness == Brightness.dark).withValues(alpha: 0.60),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}