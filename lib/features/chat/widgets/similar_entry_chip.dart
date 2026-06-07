import 'package:flutter/material.dart';
import 'package:alma_diary/features/embeddings/data/embeddings_repository.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';

class SimilarEntryChip extends StatelessWidget {
  final SimilarEntry entry;
  final bool isDark;

  const SimilarEntryChip({
    super.key,
    required this.entry,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(
        horizontal: AlmaSpacing.sm,
        vertical: AlmaSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AlmaColors.surfaceVariant(isDark),
        borderRadius: BorderRadius.circular(AlmaRadius.sm),
        border: Border.all(
          color: AlmaColors.border(isDark).withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                Icons.book_outlined,
                size: 11,
                color: AlmaColors.textMuted(isDark),
              ),
              const SizedBox(width: 4),
              Text(
                entry.formattedDate,
                style: AlmaTypography.labelSmall(
                  isDark,
                ).copyWith(color: AlmaColors.textMuted(isDark), fontSize: 10),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AlmaColors.accent(isDark).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AlmaRadius.full),
                ),
                child: Text(
                  '${(entry.similarity * 100).toInt()}%',
                  style: AlmaTypography.labelSmall(isDark).copyWith(
                    color: AlmaColors.accent(isDark).withValues(alpha: 0.8),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            entry.title.isNotEmpty ? entry.title : 'Sin título',
            style: AlmaTypography.labelSmall(
              isDark,
            ).copyWith(fontWeight: FontWeight.w600, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            entry.preview,
            style: AlmaTypography.labelSmall(isDark).copyWith(
              color: AlmaColors.textSecondary(isDark),
              fontSize: 11,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
