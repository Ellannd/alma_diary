import 'package:flutter/material.dart';

import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';


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
        final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,

      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AlmaSpacing.xxl,
        crossAxisSpacing: AlmaSpacing.xl,
        childAspectRatio: 1.1,
      ),

      children: [

             Column(
                children: [
                  Expanded(
                    child: DashboardFeatureCard(
                      icon: Icons.edit_outlined,
                      cardColor: AlmaColors.cardJournal,
                      onTap: () => Navigator.pushNamed(context, '/journal'),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Diario",
                    textAlign: TextAlign.center,
                    style: AlmaTypography.dashboardSecondary(isDark),
                  ),
                ],
              ),
            Column(
              children: [
                Expanded(
                  child: DashboardFeatureCard(
                icon: Icons.psychology_outlined,
                cardColor: AlmaColors.cardReflections, // verde azulado
                onTap: () => Navigator.pushNamed(context, '/reflections'),
              ),
            ),
              
             const SizedBox(height: 8),

                  Text(
                    "Reflexiones",
                    textAlign: TextAlign.center,
                    style: AlmaTypography.dashboardSecondary(isDark),
                  ),
              ]
            ),
             Column(
              children: [
                Expanded(
                  child: DashboardFeatureCard(
                          icon: Icons.auto_stories_outlined,
                          cardColor: AlmaColors.cardReadings, // tierra
                          onTap: () => Navigator.pushNamed(context, '/readings'),
                          ),
                        ),
              
                 const SizedBox(height: 8),

                  Text(
                    "Lecturas",
                    textAlign: TextAlign.center,
                    style: AlmaTypography.dashboardSecondary(isDark),
                  ),
              ]
            ),
             Column(
              children: [
                Expanded(
                  child: 
              DashboardFeatureCard(
                icon: Icons.show_chart_rounded,
                cardColor: AlmaColors.cardTrajectory, // azul
                onTap: () => Navigator.pushNamed(context, '/trajectory'),
              ),
                ),
                 const SizedBox(height: 8),

                  Text(
                    "Trayectoria",
                    textAlign: TextAlign.center,
                    style: AlmaTypography.dashboardSecondary(isDark),
                  ),
                  ]
            ),
              Column(
              children: [
                Expanded(
                  child: 
              DashboardFeatureCard(
                icon: Icons.format_quote_outlined,
                cardColor: AlmaColors.cardQuotes, // marrón cálido
                onTap: () => Navigator.pushNamed(context, '/quotes'),
              ),
              ),
              
                 const SizedBox(height: 8),

                  Text(
                    "Frases",
                    textAlign: TextAlign.center,
                    style: AlmaTypography.dashboardSecondary(isDark),
                  ),
                ]
            ),
            Column(
              children: [
                Expanded(
                  child: 
              DashboardFeatureCard(
                icon: Icons.track_changes_outlined,
                cardColor: AlmaColors.cardChallenges, // rojo oscuro
                onTap: () => Navigator.pushNamed(context, '/challenges'),
              ),
              ),
              
                 const SizedBox(height: 8),

                  Text(
                    "Desafíos",
                    textAlign: TextAlign.center,
                    style: AlmaTypography.dashboardSecondary(isDark),
                  ),
                  ]
            ),
      ],
    );
  }
}