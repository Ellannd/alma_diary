import 'package:alma_diary/state/dashboard/dashboard_state.dart';
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

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends ConsumerState<DashboardScreen> {

  @override
  void initState() {
    super.initState();

  
  }

  @override
  Widget build(BuildContext context) {

    ref.listenManual(dashboardControllerProvider,
        (previous, next) {
      if (previous?.navCurrentTab == next.navCurrentTab) return;

      Navigator.of(
        context).pushNamed(next.navCurrentTab.route);
    });
    
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
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom + 90,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AlmaSpacing.screenH(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardHeader(
                      onSettingsTap: () =>
                          Navigator.of(context).pushNamed('/settings'),
                    ),

                    SizedBox(height: AlmaSpacing.sectionR(context)),

                    DashboardGreeting(
                      userName: userName,
                      archetype: archetype,
                    ),

                    SizedBox(height: AlmaSpacing.sectionR(context)),

                    DashboardSection(
                      child: DashboardFeatureGrid(
                        userId: state.userId!,
                        archetype: archetype,
                        painNodes: painNodes,
                      ),
                    ),

                    SizedBox(height: AlmaSpacing.sectionR(context)),

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

                    SizedBox(height: AlmaSpacing.sectionR(context)),

                    DashboardQuoteCard(
                      quote: state.quoteText,
                      author: state.quoteSource,
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Navbar flotando encima, dentro del mismo Stack
                  Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                  left: 24,
                  right: 24,
                  child: Material(          // <-- esto fuerza su propia capa de gestos
                    color: Colors.transparent,
                    child: DashboardNavbar(
                      currentTab: state.navCurrentTab,
                      onTap: controller.setTab,
                    ),
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