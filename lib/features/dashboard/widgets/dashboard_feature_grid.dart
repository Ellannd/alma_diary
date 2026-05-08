import 'package:flutter/material.dart';

import 'package:alma_diary/design_system/tokens/alma_spacing.dart';

import 'dashboard_feature_card.dart';

class DashboardFeatureGrid extends StatelessWidget {
  final String userId;
  final String archetype;
  final List<String> painNodes;

  const DashboardFeatureGrid({
    super.key,
    required this.userId,
    required this.archetype,
    required this.painNodes,
  });

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,

      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AlmaSpacing.md,
        crossAxisSpacing: AlmaSpacing.md,
        childAspectRatio: .82,
      ),

      children: [
        DashboardFeatureCard(
          title: "Diario",
          subtitle:
              "Escribe tus pensamientos y emociones.",
          icon: Icons.edit_rounded,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/journal',
            );
          },
        ),

        DashboardFeatureCard(
          title: "Reflexiones",
          subtitle:
              "Descubre patrones emocionales internos.",
          icon: Icons.psychology_rounded,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/reflections',
            );
          },
        ),

        DashboardFeatureCard(
          title: "Lecturas",
          subtitle:
              "Explora lecturas para tu crecimiento.",
          icon: Icons.auto_stories_rounded,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/readings',
            );
          },
        ),

        DashboardFeatureCard(
          title: "Trayectoria",
          subtitle:
              "Observa tu evolución emocional.",
          icon: Icons.trending_up_rounded,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/trajectory',
            );
          },
        ),

        DashboardFeatureCard(
          title: "Desafíos",
          subtitle:
              "Pequeños retos para transformar hábitos.",
          icon: Icons.emoji_events_rounded,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/challenges',
            );
          },
        ),

        DashboardFeatureCard(
          title: "Citas",
          subtitle:
              "Frases y pensamientos para acompañarte.",
          icon: Icons.format_quote_rounded,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/quotes',
            );
          },
        ),
      ],
    );
  }
}