// lib/features/psych_profile/widgets/psych_profile_card.dart

import 'package:alma_diary/state/psych_profile/psych_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alma_diary/features/psych_profile/domain/psych_profile.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';

class PsychProfileCard extends ConsumerWidget {
  const PsychProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(psychProfileProvider);

    if (state.isLoading) {
      return _LoadingCard(isDark: isDark);
    }

    if (!state.hasProfile) {
      return _EmptyCard(isDark: isDark, isGenerating: state.isGenerating);
    }

    return _ProfileContent(
      profile: state.profile!,
      isGenerating: state.isGenerating,
      isDark: isDark,
    );
  }
}

// ── Loading ──────────────────────────────────────────────────────

class _LoadingCard extends StatelessWidget {
  final bool isDark;
  const _LoadingCard({required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AlmaSpacing.lg),
    decoration: _cardDecoration(isDark),
    child: Center(
      child: CircularProgressIndicator(
        color: AlmaColors.accent(isDark),
        strokeWidth: 2,
      ),
    ),
  );
}

// ── Sin perfil aún ───────────────────────────────────────────────

class _EmptyCard extends ConsumerWidget {
  final bool isDark;
  final bool isGenerating;
  const _EmptyCard({required this.isDark, required this.isGenerating});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    padding: const EdgeInsets.all(AlmaSpacing.lg),
    decoration: _cardDecoration(isDark),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.psychology_outlined,
          size: 40,
          color: AlmaColors.textMuted(isDark),
        ),
        const SizedBox(height: AlmaSpacing.sm),
        Text(
          'Tu perfil psicológico',
          style: AlmaTypography.h3(isDark),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AlmaSpacing.xs),
        Text(
          'Escribe al menos 3 entradas para que Alma pueda conocerte mejor.',
          style: AlmaTypography.bodySmall(
            isDark,
          ).copyWith(color: AlmaColors.textSecondary(isDark)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AlmaSpacing.md),
        _GenerateButton(isDark: isDark, isGenerating: isGenerating),
      ],
    ),
  );
}

// ── Contenido del perfil ─────────────────────────────────────────

class _ProfileContent extends ConsumerWidget {
  final PsychProfile profile;
  final bool isGenerating;
  final bool isDark;

  const _ProfileContent({
    required this.profile,
    required this.isGenerating,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    decoration: _cardDecoration(isDark),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        _ProfileHeader(
          profile: profile,
          isDark: isDark,
          isGenerating: isGenerating,
        ),

        const Divider(height: 1),

        Padding(
          padding: const EdgeInsets.all(AlmaSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumen narrativo
              if (profile.narrativeSummary != null) ...[
                Text(
                  profile.narrativeSummary!,
                  style: AlmaTypography.bodyMedium(isDark).copyWith(
                    color: AlmaColors.textSecondary(isDark),
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: AlmaSpacing.md),
              ],

              // Stats en grid 2x2
              _StatsGrid(profile: profile, isDark: isDark),

              const SizedBox(height: AlmaSpacing.md),

              // Tags por categoría
              if (profile.dominantEmotions.isNotEmpty)
                _TagSection(
                  label: 'Emociones dominantes',
                  tags: profile.dominantEmotions,
                  color: AlmaColors.emotionIntense,
                  isDark: isDark,
                ),

              if (profile.currentFocus.isNotEmpty)
                _TagSection(
                  label: 'Foco actual',
                  tags: profile.currentFocus,
                  color: AlmaColors.cardJournal,
                  isDark: isDark,
                ),

              if (profile.growthAreas.isNotEmpty)
                _TagSection(
                  label: 'Áreas de crecimiento',
                  tags: profile.growthAreas,
                  color: AlmaColors.cardReflections,
                  isDark: isDark,
                ),

              if (profile.psychologicalNeeds.isNotEmpty)
                _TagSection(
                  label: 'Necesidades',
                  tags: profile.psychologicalNeeds,
                  color: AlmaColors.cardReadings,
                  isDark: isDark,
                ),

              if (profile.copingStrategies.isNotEmpty)
                _TagSection(
                  label: 'Estrategias de afrontamiento',
                  tags: profile.copingStrategies,
                  color: AlmaColors.cardTrajectory,
                  isDark: isDark,
                ),

              if (profile.coreWounds.isNotEmpty)
                _TagSection(
                  label: 'Heridas centrales',
                  tags: profile.coreWounds,
                  color: AlmaColors.cardChallenges,
                  isDark: isDark,
                ),

              const SizedBox(height: AlmaSpacing.xs),

              // Pie con fecha y botón de regenerar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Actualizado ${profile.formattedDate}',
                    style: AlmaTypography.labelSmall(
                      isDark,
                    ).copyWith(color: AlmaColors.textMuted(isDark)),
                  ),
                  _GenerateButton(
                    isDark: isDark,
                    isGenerating: isGenerating,
                    compact: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ── Header ───────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final PsychProfile profile;
  final bool isDark;
  final bool isGenerating;

  const _ProfileHeader({
    required this.profile,
    required this.isDark,
    required this.isGenerating,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AlmaSpacing.md),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AlmaColors.accentSoft(isDark),
            borderRadius: BorderRadius.circular(AlmaRadius.sm),
          ),
          child: Icon(
            Icons.psychology_outlined,
            size: 22,
            color: AlmaColors.accent(isDark),
          ),
        ),
        const SizedBox(width: AlmaSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tu perfil psicológico', style: AlmaTypography.h3(isDark)),
              Text(
                isGenerating ? 'Actualizando...' : 'Basado en tus entradas',
                style: AlmaTypography.labelSmall(
                  isDark,
                ).copyWith(color: AlmaColors.textMuted(isDark)),
              ),
            ],
          ),
        ),
        if (isGenerating)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AlmaColors.accent(isDark),
            ),
          ),
      ],
    ),
  );
}

// ── Grid de stats ────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final PsychProfile profile;
  final bool isDark;

  const _StatsGrid({required this.profile, required this.isDark});

  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: AlmaSpacing.xs,
    mainAxisSpacing: AlmaSpacing.xs,
    childAspectRatio: 2.4,
    children: [
      _StatChip(
        label: 'Apego',
        value: profile.attachmentStyleLabel,
        icon: Icons.favorite_border_rounded,
        isDark: isDark,
      ),
      _StatChip(
        label: 'Comunicación',
        value: profile.communicationStyleLabel,
        icon: Icons.chat_bubble_outline_rounded,
        isDark: isDark,
      ),
      _StatChip(
        label: 'Patrones',
        value: '${profile.emotionalPatterns.length} detectados',
        icon: Icons.auto_graph_rounded,
        isDark: isDark,
      ),
      _StatChip(
        label: 'Entradas analizadas',
        value: '${profile.entryCountAtUpdate ?? "—"}',
        icon: Icons.book_outlined,
        isDark: isDark,
      ),
    ],
  );
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDark;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AlmaSpacing.sm,
      vertical: AlmaSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: AlmaColors.surfaceVariant(isDark),
      borderRadius: BorderRadius.circular(AlmaRadius.sm),
    ),
    child: Row(
      children: [
        Icon(icon, size: 14, color: AlmaColors.accent(isDark)),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AlmaTypography.labelSmall(
                  isDark,
                ).copyWith(color: AlmaColors.textMuted(isDark)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: AlmaTypography.labelMedium(
                  isDark,
                ).copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ── Sección de tags ──────────────────────────────────────────────

class _TagSection extends StatelessWidget {
  final String label;
  final List<String> tags;
  final Color color;
  final bool isDark;

  const _TagSection({
    required this.label,
    required this.tags,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AlmaSpacing.sm),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AlmaTypography.labelSmall(
            isDark,
          ).copyWith(color: AlmaColors.textMuted(isDark)),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: tags
              .map((tag) => _Tag(text: tag, color: color, isDark: isDark))
              .toList(),
        ),
      ],
    ),
  );
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  final bool isDark;

  const _Tag({required this.text, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: isDark ? 0.2 : 0.12),
      borderRadius: BorderRadius.circular(AlmaRadius.full),
      border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
    ),
    child: Text(
      text,
      style: AlmaTypography.labelSmall(
        isDark,
      ).copyWith(color: isDark ? color.withValues(alpha: 0.9) : color),
    ),
  );
}

// ── Botón de generar ─────────────────────────────────────────────

class _GenerateButton extends ConsumerWidget {
  final bool isDark;
  final bool isGenerating;
  final bool compact;

  const _GenerateButton({
    required this.isDark,
    required this.isGenerating,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isGenerating) {
      return Text(
        'Generando...',
        style: AlmaTypography.labelSmall(
          isDark,
        ).copyWith(color: AlmaColors.accent(isDark)),
      );
    }

    if (compact) {
      return GestureDetector(
        onTap: () => ref.read(psychProfileProvider.notifier).generateNow(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.refresh_rounded,
              size: 14,
              color: AlmaColors.accent(isDark),
            ),
            const SizedBox(width: 4),
            Text(
              'Actualizar',
              style: AlmaTypography.labelSmall(
                isDark,
              ).copyWith(color: AlmaColors.accent(isDark)),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => ref.read(psychProfileProvider.notifier).generateNow(),
        icon: Icon(
          Icons.auto_awesome_rounded,
          size: 16,
          color: AlmaColors.accent(isDark),
        ),
        label: Text(
          'Generar mi perfil',
          style: AlmaTypography.button(
            isDark,
          ).copyWith(color: AlmaColors.accent(isDark)),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: AlmaColors.accent(isDark).withValues(alpha: 0.4),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AlmaRadius.button),
          ),
          padding: const EdgeInsets.symmetric(vertical: AlmaSpacing.sm),
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────

BoxDecoration _cardDecoration(bool isDark) => BoxDecoration(
  color: AlmaColors.surface(isDark),
  borderRadius: BorderRadius.circular(AlmaRadius.card),
  border: Border.all(
    color: AlmaColors.border(isDark).withOpacity(0.08),
    width: 0.5,
  ),
);
