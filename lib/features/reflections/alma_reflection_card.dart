import 'package:flutter/material.dart';

class AlmaReflectionCard extends StatelessWidget {
  final String reflection;
  final String archetype;
  final String sentiment;
  final IconData icon;

  const AlmaReflectionCard({
    super.key,
    required this.reflection,
    required this.archetype,
    required this.sentiment,
    this.icon = Icons.psychology,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.12),
            Theme.of(context).cardColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Theme.of(context).iconTheme.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sentiment.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                    Chip(
                      label: Text(archetype),
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            reflection,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.5,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

