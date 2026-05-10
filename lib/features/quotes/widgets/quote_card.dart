import 'package:flutter/material.dart';
import 'package:alma_diary/features/quotes/engine/quotes_engine.dart';

class QuoteCard extends StatelessWidget {
  final AlmaQuote quote;
  final bool pinned;
  final VoidCallback onPin;

  const QuoteCard({
    super.key,
    required this.quote,
    required this.pinned,
    required this.onPin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: pinned
            ? primary.withValues(alpha: 0.18)
            : theme.cardColor.withValues(alpha: 0.85),
        border: Border.all(
          color: pinned ? primary : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: pinned ? 0.25 : 0.08),
            blurRadius: pinned ? 20 : 10,
            spreadRadius: pinned ? 2 : 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote,
            size: 26,
            color: primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            quote.texto,
            style: TextStyle(
              fontSize: pinned ? 19 : 17,
              height: 1.5,
              fontStyle: FontStyle.italic,
              color: onSurface,
              fontWeight: pinned ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '- ${quote.autor}',
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            quote.contextoAlma,
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.55),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (pinned)
                Text(
                  'Frase del día',
                  style: TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              GestureDetector(
                onTap: onPin,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: pinned ? 1.2 : 1.0,
                  child: Icon(
                    pinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: pinned
                        ? primary
                        : onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}