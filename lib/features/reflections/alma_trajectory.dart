import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:alma_diary/ai/engines/trajectory_engine.dart';

class AlmaTrajectoryScreen extends StatefulWidget {
  final String passphrase;
  const AlmaTrajectoryScreen({super.key, required this.passphrase});

  @override
  State<AlmaTrajectoryScreen> createState() => _AlmaTrajectoryScreenState();
}

class _AlmaTrajectoryScreenState extends State<AlmaTrajectoryScreen> {
  TrajectoryStats? _stats;
  bool _loading = true;


  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    final stats = await generar_estadisticas_trayectoria(widget.passphrase);
    setState(() {
      _stats = stats;
      _loading = false;
    });
  }

  void _showArquetipoInfo(String arquetipo) {
    String info;
    switch (arquetipo) {
      case 'The Mask':
        info =
            'La Máscara: Cuando tu lenguaje es formal o enfocado en el deber ser, puedes estar ocultando emociones auténticas.';
        break;
      case 'The Mirror':
        info =
            'El Espejo: Refleja tu capacidad de autoanálisis y proyección en otros. Indica autoconciencia.';
        break;
      case 'The Moon':
        info =
            'La Luna: Simboliza la exploración de sueños, miedos e intuiciones. Es tu mundo subconsciente.';
        break;
      default:
        info = '';
    }
 
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(arquetipo, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        content: Text(info, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar', style: TextStyle(color: Theme.of(context).primaryColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trayectoria Emocional')),
      body: _loading || _stats == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Balance de Sombra',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ShadowBalanceChart(stats: _stats!),
                      const SizedBox(height: 18),
                      // Nueva métrica de valentía
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt, color: Theme.of(context).colorScheme.primary, size: 28),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              'Valentía acumulada: ',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            '${_stats!.valentia.toInt()}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface ,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 10),
                      Text(
                        'Evolución de Arquetipos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _stats!.arquetipos.keys
                            .map(
                              (k) => GestureDetector(
                                onTap: () => _showArquetipoInfo(k),
                                child: _ArquetipoCircle(
                                  label: k,
                                  value: _stats!.arquetipos[k]!,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        '¿Qué has mejorado?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _stats!.narrativa,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (_stats!.conceptos.isNotEmpty) ...[
                        Text(
                          'Estadísticas Interesantes',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          children: _stats!.conceptos
                              .map(
                                (c) => Chip(
                                  label: Text(
                                    c,
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 32),
                      if (_stats!.hitos.isNotEmpty) ...[
                        AnimatedHitoBanner(hito: _stats!.hitos.first),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
                if (_stats!.hitos.isNotEmpty)
                  const Positioned.fill(child: ConfettiOverlay()),
              ],
            ),
    );
  }
}

class _ShadowBalanceChart extends StatelessWidget {
  final TrajectoryStats stats;
  const _ShadowBalanceChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, stats.conscienciaDeSi),
                FlSpot(1, stats.agenciaPersonal),
                FlSpot(2, stats.integracionSombra),
                FlSpot(3, stats.rumiacion),
              ],
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 6,
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).appBarTheme.foregroundColor,
              ),
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArquetipoCircle extends StatelessWidget {
  final String label;
  final double value;
  const _ArquetipoCircle({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.2),
              ),
            ),
            Text(
              '${value.round()}%',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }
}

class AnimatedHitoBanner extends StatefulWidget {
  final String hito;
  const AnimatedHitoBanner({super.key, required this.hito});
  @override
  State<AnimatedHitoBanner> createState() => _AnimatedHitoBannerState();
}

class _AnimatedHitoBannerState extends State<AnimatedHitoBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) => Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        margin: const EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Theme.of(context).primaryColor.withValues(alpha: 0.18 + 0.18 * _glowAnim.value),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25 * _glowAnim.value),
              blurRadius: 24 * _glowAnim.value,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.emoji_events, color: Theme.of(context).highlightColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.hito,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});
  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Offset> _confetti;
  final int _count = 18;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
    _confetti = List.generate(
      _count,
      (i) =>
          Offset(0.1 + 0.8 * (i / _count), 0.1 + 0.8 * (i.isEven ? 0.2 : 0.8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
          painter: _ConfettiPainter(
            _controller.value,
            _confetti,
            Theme.of(context).colorScheme.primary,
            ),
        );
        },
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<Offset> confetti;
  final Color color;

  _ConfettiPainter(this.progress, this.confetti, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 1 - progress);

    for (final c in confetti) {
      final dx = c.dx * size.width +
          (progress * 40 * (c.dx - 0.5));
      final dy = c.dy * size.height +
          (progress * 120 * (c.dy - 0.5));

      canvas.drawCircle(
        Offset(dx, dy),
        8 - 6 * progress,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.confetti != confetti ||
        oldDelegate.color != color;
  }
}
