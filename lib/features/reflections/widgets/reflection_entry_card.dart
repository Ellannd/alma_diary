import "package:alma_diary/design_system/tokens/alma_colors.dart";
import "package:alma_diary/design_system/tokens/alma_spacing.dart";
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final date = DateTime.tryParse(rawDate?.toString() ?? '') ??
        DateTime.now();

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: AlmaSpacing.r(context, 16), vertical: AlmaSpacing.r(context, 10)),
        padding: EdgeInsets.all(AlmaSpacing.r(context, 18)),
        decoration: BoxDecoration(
          border: Border.all(color: AlmaColors.textPrimary(isDark).withValues(alpha: 0.80), width: 0.5),
          borderRadius: BorderRadius.circular(24),
          

        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReflectionDateChip(date: date),

            SizedBox(height: AlmaSpacing.r(context,  12)),

            ReflectionTags(
              archetype: archetype,
              sentiment: sentiment,
            ),

            SizedBox(height: AlmaSpacing.r(context,  14)),

            Text(
              content.length > 140
                  ? '${content.substring(0, 140)}...'
                  : content,
            ),

            SizedBox(height: AlmaSpacing.r(context,  10)),

            Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.arrow_forward_ios,
                size: AlmaSpacing.r(context,  14),
                color: Colors.grey.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}