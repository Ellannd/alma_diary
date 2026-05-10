import 'package:flutter/material.dart';

class ReflectionCard extends StatelessWidget {
  final String reflection;
  final String archetype;
  final String sentiment;
  final IconData icon;
  final bool highlighted;
  final VoidCallback? onTap;

  const ReflectionCard({
    super.key,
    required this.reflection,
    required this.archetype,
    required this.sentiment,
    this.icon = Icons.psychology,
    this.highlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primary = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: highlighted
              ? primary.withValues(alpha: isDark ? 0.18 : 0.10)
              : surface,

          borderRadius: BorderRadius.circular(20),

          border: Border.all(
            color: highlighted
                ? primary.withValues(alpha: 0.6)
                : onSurface.withValues(alpha: 0.08),
          ),

          boxShadow: [
            if (highlighted)
              BoxShadow(
                color: primary.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: primary),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sentiment.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: primary,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        archetype,
                        style: TextStyle(
                          fontSize: 13,
                          color: onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // CONTENT
            Text(
              reflection,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}