import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/dashboard_background.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_greeting.dart';
import '../widgets/dashboard_feature_grid.dart';
import '../widgets/dashboard_quote_card.dart';
import '../widgets/dashboard_mood_card.dart';
import '../widgets/dashboard_section.dart';
import '../widgets/dashboard_navbar.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';

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
      body: Stack(
        children: [
          // =========================
          // BACKGROUND
          // =========================
          DashboardBackground(
            child: SafeArea(
              child: Column(
                children: [
                  // =========================
                  // HEADER
                  // =========================
                  DashboardHeader(
                    userName: userName,
                    archetype: archetype,
                  ),

                  const SizedBox(height: 16),

                  // =========================
                  // GREETING
                  // =========================
                  DashboardGreeting(
                    userName: userName,
                    archetype: archetype,
                  ),

                  const SizedBox(height: 20),

                  // =========================
                  // CONTENT
                  // =========================
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                        bottom: 120,
                        left: 20,
                        right: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DashboardSection(
                            title: "Tu espacio",
                            child: DashboardFeatureGrid(
                              userId: state.userId!, archetype: archetype, painNodes: painNodes,
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

                          const SizedBox(height: 16),

                          DashboardQuoteCard(
                            quote: state.quoteText,
                            author: state.quoteSource,
),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =========================
          // NAVBAR (STATE-DRIVEN)
          // =========================
          DashboardNavbar(
            currentIndex: state.currentIndex,
            onTap: controller.setTab,
          ),
        ],
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