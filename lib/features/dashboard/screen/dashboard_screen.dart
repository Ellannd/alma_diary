import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/dashboard_background.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_feature_grid.dart';
import '../widgets/dashboard_quote_card.dart';
import '../widgets/dashboard_mood_card.dart';
import '../widgets/dashboard_section.dart';
import '../widgets/dashboard_navbar.dart';
import '../widgets/dashboard_greeting.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';

import 'package:alma_diary/state/dashboard/dashboard_controller.dart';
import "package:alma_diary/state/theme/theme_controller.dart";

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // =========================
    // STATE ÚNICO 
    // =========================
    final state = ref.watch(dashboardControllerProvider);
    final controller = ref.read(dashboardControllerProvider.notifier);

    final theme = ref.watch(themeProvider);
    final isDark = theme.isDarkMode;

    if (state.isLoading || state.userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userName = state.profile?['name']
        ?? state.profile?['full_name']
        ?? 'Usuario';

    final archetype = state.archetype;

    final painNodes = state.painNodes;

  return Scaffold(
  backgroundColor: Colors.transparent,
  // Quita extendBody y bottomNavigationBar
  body: DashboardBackground(
    child: Stack(
      children: [
        // Todo el scroll aquí
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AlmaSpacing.lg,
                        vertical: AlmaSpacing.sm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DashboardHeader(
                            onSettingsTap: () =>
                                Navigator.of(context).pushNamed('/settings'),
                          ),

                          const SizedBox(height: 24),

                          DashboardGreeting(
                            userName: userName,
                            archetype: archetype,
                          ),
                        ],
                      ),
                    ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      DashboardSection(
                        child: DashboardFeatureGrid(
                          userId: state.userId!,
                          archetype: archetype,
                          painNodes: painNodes,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DashboardMoodCard(
                        title: state.moodTitle,
                        subtitle: state.moodSubtitle,
                        mood: state.mood,
                        icon: Icon(
                          MoodIconMapper.fromKey(state.moodIconKey),
                          color: AlmaColors.accent(isDark),
                        ),
                        onTap: () {},
                      ),
                      const SizedBox(height: 20),
                      DashboardQuoteCard(
                        quote: state.quoteText,
                        author: state.quoteSource,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Navbar flotando encima, dentro del mismo Stack
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          left: 24,
          right: 24,
          child: DashboardNavbar(
            currentIndex: state.currentIndex,
            onTap: controller.setTab,
          ),
        ),
      ],
    ),
  ),
);
    
  }
}


class MoodIconMapper {
  static IconData fromKey(String key) {
    switch (key) {
      case 'self_improvement':
        return Icons.self_improvement;
      case 'favorite':
        return Icons.favorite;
      case 'psychology':
        return Icons.psychology;
      case 'bolt':
        return Icons.bolt;
      default:
        return Icons.circle_outlined;
    }
  }
}