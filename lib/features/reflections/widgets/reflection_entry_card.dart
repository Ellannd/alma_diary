import "package:flutter/material.dart";
import 'reflection_date_chip.dart';
import "reflection_tags.dart";

class ReflectionEntryCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final VoidCallback onTap;

  const ReflectionEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = entry['content_decrypted'] ??
        entry['content_encrypted'] ??
        '';

    final archetype = entry['archetype'] ?? '';
    final sentiment = entry['sentiment'] ?? '';

    final rawDate = entry['created_at'];
    final date = DateTime.tryParse(rawDate?.toString() ?? '') ??
        DateTime.now();

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
              Theme.of(context).cardColor,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReflectionDateChip(date: date),

            const SizedBox(height: 12),

            ReflectionTags(
              archetype: archetype,
              sentiment: sentiment,
            ),

            const SizedBox(height: 14),

            Text(
              content.length > 140
                  ? '${content.substring(0, 140)}...'
                  : content,
            ),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}