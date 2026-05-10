import 'package:flutter/material.dart';

class AnimatedHitoBanner extends StatefulWidget {
  final String hito;

  const AnimatedHitoBanner({
    super.key,
    required this.hito,
  });

  @override
  State<AnimatedHitoBanner> createState() =>
      _AnimatedHitoBannerState();
}

class _AnimatedHitoBannerState
    extends State<AnimatedHitoBanner>
    with SingleTickerProviderStateMixin {

  late final AnimationController _controller;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glow = Tween<double>(
      begin: 0.4,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _glow,

      builder: (_, __) {
        return Container(
          padding: const EdgeInsets.all(20),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),

            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primary.withValues(alpha: 0.18),
                primary.withValues(alpha: 0.06),
              ],
            ),

            boxShadow: [
              BoxShadow(
                color: primary.withValues(
                  alpha: 0.22 * _glow.value,
                ),
                blurRadius: 30 * _glow.value,
                spreadRadius: 2,
              ),
            ],
          ),

          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: 0.15),
                ),

                child: Icon(
                  Icons.emoji_events,
                  color: primary,
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  widget.hito,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}