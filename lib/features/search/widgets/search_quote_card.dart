import 'package:flutter/material.dart';

class SearchQuoteCard extends StatelessWidget {
  final String quote;
  final String? author;

  const SearchQuoteCard({
    super.key,
    required this.quote,
    this.author,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.10),
            colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote_rounded,
            color: colorScheme.primary,
            size: 28,
          ),

          const SizedBox(height: 14),

          Text(
            quote,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),

          if (author != null && author!.isNotEmpty) ...[
            const SizedBox(height: 18),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '— $author',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}