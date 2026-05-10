import 'package:flutter/material.dart';

class SearchEmptyState extends StatelessWidget {
  final String message;
  final String helperMessage;
  const SearchEmptyState({super.key, required this.message, required this.helperMessage});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 42,
                color: colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              helperMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.58),
                height: 1.5,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}