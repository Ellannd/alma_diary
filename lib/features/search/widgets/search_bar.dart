import 'package:flutter/material.dart';

class AlmaSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool loading;

  const AlmaSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),

          Icon(
            Icons.search,
            color: colorScheme.onSurface.withValues(alpha: 0.55),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar emociones, símbolos o recuerdos...',
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.42),
                ),
                border: InputBorder.none,
              ),
            ),
          ),

          if (loading)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}