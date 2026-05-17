import 'package:alma_diary/state/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alma_diary/state/dashboard/dashboard_state.dart';
import 'package:alma_diary/state/dashboard/dashboard_controller.dart';
import 'package:alma_diary/state/theme/theme_controller.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';

import '../widgets/dashboard_background.dart';
import '../widgets/dashboard_navbar.dart';

import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_feature_grid.dart';
import '../widgets/dashboard_quote_card.dart';
import '../widgets/dashboard_mood_card.dart';
import '../widgets/dashboard_section.dart';
import '../widgets/dashboard_greeting.dart';
import 'package:alma_diary/features/search/screen/search_screen.dart';
import 'package:alma_diary/features/journal/screen/create_page.dart';
import 'package:alma_diary/features/notifications/screen/notifications_page.dart';
import 'package:alma_diary/features/profile/presentation/screen/profile_page.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // Lazy initialization — solo construye cada página la primera vez que se visita
  final List<Widget?> _cachedPages = List.filled(NavbarTab.values.length, null);

  Widget _buildTab(NavbarTab tab, DashboardState state, bool isDark) {
    switch (tab) {
      case NavbarTab.dashboard:
        return _DashboardHome();
      case NavbarTab.search:
      // Para la demo, el passphrase es fijo y no deberia pasarse aquí. En producción, se podría generar dinámicamente o pedir al usuario.
        return const Center(child: SearchScreen(passphrase: "alma_biometric_pass")); 
      case NavbarTab.create:
        return const Center(child: CreatePage()); 
      case NavbarTab.notifications:
        return const Center(child: NotificationsPage()); 
      case NavbarTab.profile:
        return const Center(child: ProfilePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardControllerProvider);
    final controller = ref.read(dashboardControllerProvider.notifier);
    
    final theme = ref.watch(themeProvider);
    final isDark = theme.isDarkMode;

    if (state.isLoading || state.userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentIndex = NavbarTab.values.indexOf(state.navCurrentTab);

    // Lazy: construye la página solo si aún no existe
    _cachedPages[currentIndex] ??= _buildTab(state.navCurrentTab, state, isDark);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DashboardBackground(
        child: Stack(
          children: [
            // IndexedStack con lazy initialization
            IndexedStack(
              index: currentIndex,
              children: List.generate(
                NavbarTab.values.length,
                (i) => _cachedPages[i] ?? const SizedBox.shrink(),
              ),
            ),

            // Navbar flotante
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 24,
              right: 24,
              child: Material(
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

// =====================
// TAB: DASHBOARD HOME
// =====================
class _DashboardHome extends ConsumerWidget {
  const _DashboardHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardControllerProvider);
    final isDark = ref.watch(themeProvider).isDarkMode;
    final userName = ref.watch(
    profileControllerProvider.select((state) => state.displayName),
  );

    return SafeArea(
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
                archetype: state.archetype,
              ),

              SizedBox(height: AlmaSpacing.sectionR(context)),

              DashboardSection(
                child: DashboardFeatureGrid(
                  userId: state.userId!,
                  archetype: state.archetype,
                  painNodes: state.painNodes,
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
    );
  }
}

// =====================
// MOOD ICON MAPPER
// =====================
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