import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alma_diary/state/reflections/reflection_controller.dart';
import 'package:alma_diary/features/reflections/engine/trajectory_engine.dart';

import '../widgets/trajectory/trajectory_chart.dart';
import '../widgets/trajectory/trajectory_section_title.dart';
import '../widgets/trajectory/trajectory_stat_tile.dart';
import '../widgets/trajectory/archetype_circle.dart';
import '../widgets/trajectory/trajectory_concepts_wrap.dart';
import '../widgets/trajectory/trajectory_narrative_card.dart';
import '../widgets/trajectory/animated_hito_banner.dart';
import '../widgets/trajectory/confetti_overlay.dart';
import '../widgets/trajectory/archetype_info_dialog.dart';

class AlmaTrajectoryScreen extends ConsumerStatefulWidget {
  final String passphrase;

  const AlmaTrajectoryScreen({
    super.key,
    required this.passphrase,
  });

  @override
  ConsumerState<AlmaTrajectoryScreen> createState() =>
      _AlmaTrajectoryScreenState();
}

class _AlmaTrajectoryScreenState
    extends ConsumerState<AlmaTrajectoryScreen> {

  TrajectoryStats? _stats;

  bool _loadingStats = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initialize();
    });
  }

  Future<void> _initialize() async {
    await ref
        .read(reflectionControllerProvider.notifier)
        .loadEntries();

    await _loadTrajectory();
  }

  Future<void> _loadTrajectory() async {
    setState(() {
      _loadingStats = true;
      _error = null;
    });

    try {
      final stats =
          await generar_estadisticas_trayectoria(
        widget.passphrase,
      );

      if (!mounted) return;

      setState(() {
        _stats = stats;
        _loadingStats = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loadingStats = false;
        _error =
            'No se pudo cargar la trayectoria emocional.';
      });
    }
  }

  Future<void> _refresh() async {
    await ref
        .read(reflectionControllerProvider.notifier)
        .refresh();

    await _loadTrajectory();
  }

  @override
  Widget build(BuildContext context) {
    final reflectionState =
        ref.watch(reflectionControllerProvider);

    final stats = _stats;

    final isLoading =
        reflectionState.loading || _loadingStats;

    return Scaffold(
      appBar: AppBar(

      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(24),

                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: AlmaSpacing.r(context,16),
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface,
                      ),
                    ),
                  ),
                )
              : stats == null
                  ? Center(
                      child: Text(
                        'No hay datos suficientes todavía.',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface,
                        ),
                      ),
                    )
                  : Stack(
                      children: [
                        RefreshIndicator(
                          onRefresh: _refresh,

                          child: SingleChildScrollView(
                            physics:
                                const AlwaysScrollableScrollPhysics(),

                            padding:
                                EdgeInsets.all(AlmaSpacing.r(context,28)),

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .center,

                              children: [
                                /// =====================
                                /// BALANCE
                                /// =====================
                                const TrajectorySectionTitle(
                                  title:
                                      'Balance de Sombra',
                                ),

                                SizedBox(
                                  height: AlmaSpacing.r(context,18),
                                ),

                                TrajectoryChart(
                                  stats: stats,
                                ),

                               SizedBox(
                                  height: AlmaSpacing.r(context,24),
                                ),

                                TrajectoryStatTile(
                                  icon: Icons.bolt,
                                  label:
                                      'Valentía acumulada',
                                  value: stats
                                      .valentia
                                      .toInt()
                                      .toString(),
                                ),

                                SizedBox(
                                  height: AlmaSpacing.r(context,36),
                                ),

                                /// =====================
                                /// ARQUETIPOS
                                /// =====================
                                const TrajectorySectionTitle(
                                  title:
                                      'Evolución de Arquetipos',
                                ),

                                SizedBox(
                                  height: AlmaSpacing.r(context,22),
                                ),

                                Wrap(
                                  spacing: 18,
                                  runSpacing: 18,

                                  children: stats
                                      .arquetipos
                                      .entries
                                      .map(
                                        (entry) {
                                          return ArchetypeCircle(
                                            label:
                                                entry.key,
                                            value:
                                                entry
                                                    .value,

                                            onTap: () {
                                              showArchetypeInfoDialog(
                                                context,
                                                entry.key,
                                              );
                                            },
                                          );
                                        },
                                      )
                                      .toList(),
                                ),

                                SizedBox(
                                  height: AlmaSpacing.r(context,36),
                                ),

                                /// =====================
                                /// NARRATIVA
                                /// =====================
                                const TrajectorySectionTitle(
                                  title:
                                      '¿Qué has mejorado?',
                                ),

                                SizedBox(
                                  height: AlmaSpacing.r(context,18),
                                ),

                                TrajectoryNarrativeCard(
                                  narrative:
                                      stats.narrativa,
                                ),

                                SizedBox(
                                  height: AlmaSpacing.r(context,36),
                                ),

                                /// =====================
                                /// CONCEPTOS
                                /// =====================
                                if (stats
                                    .conceptos
                                    .isNotEmpty) ...[
                                  const TrajectorySectionTitle(
                                    title:
                                        'Estadísticas Interesantes',
                                  ),

                                  SizedBox(
                                    height: AlmaSpacing.r(context,18),
                                  ),

                                  TrajectoryConceptsWrap(
                                    concepts:
                                        stats.conceptos,
                                  ),

                                  SizedBox(
                                    height: AlmaSpacing.r(context,36),
                                  ),
                                ],

                                /// =====================
                                /// HITOS
                                /// =====================
                                if (stats
                                    .hitos
                                    .isNotEmpty) ...[
                                  const TrajectorySectionTitle(
                                    title:
                                        'Hitos alcanzados',
                                  ),

                                  SizedBox(
                                    height: AlmaSpacing.r(context,18),
                                  ),

                                  AnimatedHitoBanner(
                                    hito: stats
                                        .hitos
                                        .first,
                                  ),
                                ],

                                SizedBox(
                                  height: AlmaSpacing.r(context,40),
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (stats.hitos.isNotEmpty)
                          const Positioned.fill(
                            child:
                                ConfettiOverlay(),
                          ),
                      ],
                    ),
    );
  }
}