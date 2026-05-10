import 'package:flutter/material.dart';

class ArchetypeFilterChips extends StatelessWidget {
  final List<String> archetypes;
  final String? selected;
  final ValueChanged<String> onSelected;

  const ArchetypeFilterChips({
    super.key,
    required this.archetypes,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: archetypes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final item = archetypes[index];
          final isSelected = item == selected;

          return ChoiceChip(
            label: Text(item),
            selected: isSelected,
            onSelected: (_) => onSelected(item),
            showCheckmark: false,
            selectedColor: colorScheme.primary,
            backgroundColor: colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.45),
            side: BorderSide(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.08),
            ),
            labelStyle: TextStyle(
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }
}