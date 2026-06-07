// lib/ai/chat/widgets/similar_entries_strip.dart

import 'package:alma_diary/features/chat/widgets/similar_entry_chip.dart';
import 'package:flutter/material.dart';
import 'package:alma_diary/features/embeddings/data/embeddings_repository.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';

class SimilarEntriesStrip extends StatelessWidget {
  final List<SimilarEntry> entries;
  final bool isDark;

  const SimilarEntriesStrip({
    super.key,
    required this.entries,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(
        left: AlmaSpacing.xs,
        right: AlmaSpacing.md,
        bottom: AlmaSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 11,
                color: AlmaColors.textMuted(isDark),
              ),
              const SizedBox(width: 4),
              Text(
                'Recuerdo que escribiste sobre esto',
                style: AlmaTypography.labelSmall(
                  isDark,
                ).copyWith(color: AlmaColors.textMuted(isDark), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) =>
                  SimilarEntryChip(entry: entries[i], isDark: isDark),
            ),
          ),
        ],
      ),
    );
  }
}
