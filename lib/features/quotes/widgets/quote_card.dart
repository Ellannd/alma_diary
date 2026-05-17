import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
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

    return Container(
      padding: EdgeInsets.all(AlmaSpacing.r(context, 22)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: pinned
            ? AlmaColors.transparent
            : theme.cardColor.withValues(alpha: 0.85),
        border: Border.all(
          color: AlmaColors.glass(Theme.of(context).brightness==Brightness.dark),
          width: 1.5,
        ),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote,
            size: 26,
            color: primary.withValues(alpha: 0.6),
          ),
          SizedBox(height: AlmaSpacing.r(context,12)),
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
          SizedBox(height: AlmaSpacing.r(context,12)),
          Text(
            '- ${quote.autor}',
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          SizedBox(height: AlmaSpacing.r(context,12)),
          Text(
            quote.contextoAlma,
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.55),
              fontSize: 13,
            ),
          ),
          SizedBox(height: AlmaSpacing.r(context,16)),
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
                 Icon(
                    pinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: pinned
                        ? primary
                        : onSurface.withValues(alpha: 0.5),
                  ),
            
          
            ],
          ),
        ],
      ),
    );
  }
}