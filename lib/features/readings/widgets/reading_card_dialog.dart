import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class ReadingCardDialog extends StatelessWidget {
  final Map<String, dynamic> rec;

  const ReadingCardDialog({
    super.key,
    required this.rec,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Blur de fondo
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(color: Colors.black.withValues(alpha: .3)),
          ),
        ),

        // Dialog encima
        Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.all(AlmaSpacing.r(context, AlmaSpacing.lg)),
          child: Container(
            padding: EdgeInsets.all(AlmaSpacing.r(context, AlmaSpacing.lg)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AlmaRadius.sheet),
              color: AlmaColors.surface(isDark).withValues(alpha: .92),
              border: Border.all(
                color: AlmaColors.border(isDark).withValues(alpha: .15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .2),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        rec['title'] ?? '',
                        style: AlmaTypography.h3(isDark, context).copyWith(fontSize: AlmaSpacing.r(context, AlmaSpacing.lg)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AlmaColors.surfaceVariant(isDark),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: AlmaColors.textMuted(isDark),
                        ),
                      ),
                    ),
                  ],
                ),

                if (rec['author'] != null) ...[
                  SizedBox(height: AlmaSpacing.r(context, AlmaSpacing.md+2)),
                  Text(
                    rec['author'],
                    style: AlmaTypography.labelMedium(isDark, context).copyWith(
                      color: AlmaColors.accent(isDark),
                    ),
                  ),
                ],

                SizedBox(height: AlmaSpacing.r(context, AlmaSpacing.md)),

                Divider(color: AlmaColors.border(isDark).withValues(alpha: .12)),

                SizedBox(height: AlmaSpacing.r(context, AlmaSpacing.md)),

                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.4,
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      rec['content'].toString().replaceAll(r'\n', ' '),
                      style: AlmaTypography.h3(isDark, context).copyWith(
                        color: AlmaColors.textSecondary(isDark),
                        height: 1.6,
                        fontWeight: FontWeight.w400
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}