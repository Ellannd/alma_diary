import 'package:flutter/material.dart';

import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';
import 'package:alma_diary/design_system/tokens/alma_responsive.dart';


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

        final gap = AlmaSpacing.gridGapR(context);
           // Altura de card proporcional al ancho disponible
        final cardWidth =
            (AlmaResponsive.screenWidth(context) -
                    AlmaSpacing.screenPadding * 2 -
                    gap) /
                2;
        final cardHeight = cardWidth * 1.15;


    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,

      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: gap,
        crossAxisSpacing: gap,
        childAspectRatio: cardWidth / cardHeight + 0.15,
      ),

      children: [

             Column(
                children: [
                  Expanded(
                    child: DashboardFeatureCard(
                      icon: Icons.edit_outlined,
                      cardColor: AlmaColors.cardJournal,
                      onTap: () => Navigator.of(context).pushNamed('/journal'),
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
                onTap: () => Navigator.of(context).pushNamed('/reflections'),
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
                          onTap: () => Navigator.of(context).pushNamed('/readings'),
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
                onTap: () => Navigator.of(context).pushNamed('/trajectory'),
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
                onTap: () => Navigator.of(context).pushNamed('/quotes'),
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
                onTap: () => Navigator.of(context).pushNamed('/challenges'),
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