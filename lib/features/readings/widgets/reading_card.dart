import 'package:flutter/material.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';
import 'package:alma_diary/features/readings/widgets/reading_card_dialog.dart';

class ReadingCard extends StatelessWidget {
  final dynamic rec;
  final bool saved;
  final bool helped;
  final VoidCallback onSave;
  final VoidCallback onHelped;

  const ReadingCard({
    super.key,
    required this.rec,
    required this.saved,
    required this.helped,
    required this.onSave,
    required this.onHelped,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;


    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: .15),
        builder: (_) => ReadingCardDialog(rec: rec),
      ),
      child: Container(
        padding: EdgeInsets.all(AlmaSpacing.cardPaddingR(context)),
        decoration: BoxDecoration(
          color: AlmaColors.surface(isDark),
          borderRadius: BorderRadius.circular(AlmaRadius.card),
          border: Border.all(color: AlmaColors.border(isDark).withValues(alpha: .12)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rec['title'] ?? '',
                    style: AlmaTypography.h3(isDark, context).copyWith(fontWeight: FontWeight.bold, fontSize: AlmaSpacing.r(context, AlmaSpacing.md+2)),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    rec['content'].toString().replaceAll(r'\n', ' '),
                    style: AlmaTypography.h3(isDark, context).copyWith(
                      color: AlmaColors.textSecondary(isDark),
                      fontWeight: FontWeight.w200,
                      fontSize: AlmaSpacing.r(context, 14)
                      
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: AlmaSpacing.r(context, AlmaSpacing.sm)),

                  Row(
                    children: [
                      _ActionButton(
                        label: saved ? 'Guardar' : 'Guardada',
                        isDark: isDark,
                        onPressed: onSave,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: AlmaSpacing.r(context, AlmaSpacing.md)),

           ClipRRect(
                borderRadius: BorderRadius.circular(
                  AlmaRadius.md,
                ),
                child:
                      _PlaceholderCover(
                        isDark: isDark,
                        index:  rec['id'].hashCode.abs() % 4,
                      ),
                ),
      
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool isDark;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.isDark,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AlmaSpacing.r(context, 32),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AlmaColors.info.withValues(alpha: 0.70),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AlmaRadius.full),
          ),
          textStyle: AlmaTypography.labelMedium(isDark, context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _PlaceholderCover extends StatelessWidget {
  final int index;
  final bool isDark;
  const _PlaceholderCover({required this.isDark, required this.index});

  static const placeholders = [
          'assets/readings/placeholder1.png',
          'assets/readings/placeholder2.png',
          'assets/readings/placeholder3.png',
          'assets/readings/placeholder4.png',
];

 @override
  Widget build(BuildContext context) {
    final image =
        placeholders[index % placeholders.length];

    return ClipRRect(
      borderRadius: BorderRadius.circular(
        AlmaRadius.md,
      ),
      child: Image.asset(
        image,
        width: AlmaSpacing.r(context, 120),
        height: AlmaSpacing.r(context, 120),
        fit: BoxFit.cover,
      ),
    );
  }
}