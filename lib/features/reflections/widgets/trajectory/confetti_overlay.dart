import 'package:flutter/material.dart';

class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});

  @override
  State<ConfettiOverlay> createState() =>
      _ConfettiOverlayState();
}

class _ConfettiOverlayState
    extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {

  late final AnimationController _controller;

  late final List<Offset> _particles;

  static const int _count = 18;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _particles = List.generate(
      _count,
      (i) {
        return Offset(
          0.1 + (0.8 * (i / _count)),
          i.isEven ? 0.2 : 0.8,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,

        builder: (_, __) {
          return CustomPaint(
            painter: _ConfettiPainter(
              progress: _controller.value,
              particles: _particles,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
          );
        },
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<Offset> particles;
  final Color color;

  const _ConfettiPainter({
    required this.progress,
    required this.particles,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 1 - progress);

    for (final p in particles) {
      final dx =
          p.dx * size.width +
          (progress * 40 * (p.dx - 0.5));

      final dy =
          p.dy * size.height +
          (progress * 120 * (p.dy - 0.5));

      canvas.drawCircle(
        Offset(dx, dy),
        8 - (6 * progress),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _ConfettiPainter oldDelegate,
  ) {
    return oldDelegate.progress != progress;
  }
}