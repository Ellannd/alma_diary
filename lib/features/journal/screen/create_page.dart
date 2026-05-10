// lib/features/journal/screens/create_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

import 'journal_editor_screen.dart';

class CreatePage extends ConsumerWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(
            AlmaSpacing.xl,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // =========================
              // HERO ICON
              // =========================
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AlmaColors.accent(isDark)
                      .withValues(alpha: .10),
                  border: Border.all(
                    color: AlmaColors.accent(isDark)
                        .withValues(alpha: .18),
                  ),
                ),
                child: Icon(
                  Icons.edit_note_rounded,
                  size: 58,
                  color: AlmaColors.accent(isDark),
                ),
              ),

              const SizedBox(height: AlmaSpacing.xl),

              // =========================
              // TITLE
              // =========================
              Text(
                'Nueva entrada',
                textAlign: TextAlign.center,
                style: AlmaTypography.h1(isDark),
              ),

              const SizedBox(height: AlmaSpacing.md),

              // =========================
              // DESCRIPTION
              // =========================
              Text(
                'La única salida es atravesarlo.\nAlma analizará tus emociones,\npatrones y reflexiones.',
                textAlign: TextAlign.center,
                style: AlmaTypography.bodyLarge(isDark)
                    .copyWith(
                  color:
                      AlmaColors.textSecondary(isDark),
                  height: 1.6,
                ),
              ),

              const SizedBox(height: AlmaSpacing.xxxl),

              // =========================
              // CTA
              // =========================
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const JournalEditorScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.auto_awesome_rounded,
                  ),
                  label: Text(
                    'Escribir diario',
                    style:
                        AlmaTypography.labelLarge(
                      isDark,
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor:
                        AlmaColors.accent(isDark),
                    foregroundColor:
                        AlmaColors.accent(isDark),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        AlmaRadius.xl,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AlmaSpacing.md),

              // =========================
              // CANCEL
              // =========================
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                ),
                label: Text(
                  'Cancelar',
                  style:
                      AlmaTypography.labelMedium(
                    isDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}