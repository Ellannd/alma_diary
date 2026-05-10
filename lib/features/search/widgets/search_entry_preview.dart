import 'package:flutter/material.dart';

class SearchEntryPreview extends StatelessWidget {
  final String content;

  const SearchEntryPreview({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.08),
        ),
      ),
      child: Text(
        content,
        style: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.82),
          fontSize: 15,
          height: 1.6,
        ),
      ),
    );
  }
}