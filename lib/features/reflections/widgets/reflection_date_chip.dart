import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:flutter/material.dart';

class ReflectionDateChip extends StatelessWidget {
  final DateTime date;

  const ReflectionDateChip({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AlmaSpacing.r(context, 10),
            vertical: AlmaSpacing.r(context, 6),
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${date.day.toString().padLeft(2, '0')}/'
            '${date.month.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: AlmaSpacing.r(context, 13),
            ),
          ),
        ),

        const Spacer(),

        Icon(
          Icons.auto_awesome,
          size: AlmaSpacing.r(context, 18),
          color: theme.colorScheme.primary.withValues(alpha: 0.6),
        ),
      ],
    );
  }
}