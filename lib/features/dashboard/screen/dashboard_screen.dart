import 'package:alma_diary/design_system/components/feedback/alma_loader.dart';
import 'package:alma_diary/state/notifications/notifications_controller.dart';
import 'package:alma_diary/state/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alma_diary/state/dashboard/dashboard_state.dart';
import 'package:alma_diary/state/dashboard/dashboard_controller.dart';
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

  Widget _buildTab(NavbarTab tab) {
    switch (tab) {
      case NavbarTab.dashboard:
        return const _DashboardHome();
      case NavbarTab.search:
        return const Center(child: SearchScreen()); 
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
      final currentTab = ref.watch(
    dashboardControllerProvider.select((s) => s.navCurrentTab),
  );
  final isLoading = ref.watch(
    dashboardControllerProvider.select((s) => s.isLoading),
  );
  final userId = ref.watch(
    dashboardControllerProvider.select((s) => s.userId),
  );
  final notificationCount = ref.watch(
    notificationControllerProvider.select((s) => s.unreadCount),
  );
  final controller = ref.read(dashboardControllerProvider.notifier);

  if (isLoading || userId == null) {
    return const Scaffold(
      body: Center(child: AlmaLoader()),
    );
  }

    final currentIndex = NavbarTab.values.indexOf(currentTab);

    // Lazy: construye la página solo si aún no existe
    _cachedPages[currentIndex] ??= _buildTab(currentTab);

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
                  currentTab: currentTab,
                  onTap: controller.setTab,
                  notificationCount: notificationCount,
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
  const _DashboardHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   
    final archetype = ref.watch(
      dashboardControllerProvider.select((s) => s.archetype)
    );
    final userName = ref.watch(
        profileControllerProvider.select((s) => s.value?.displayName),
      );
    final userId = ref.watch(
      dashboardControllerProvider.select((s) => s.userId)
    );
    final painNodes = ref.watch(
      dashboardControllerProvider.select((s) => s.painNodes)
    );
    final moodTitle = ref.watch(
      dashboardControllerProvider.select((s) => s.moodTitle)
    );
    final moodSubtitle = ref.watch(
      dashboardControllerProvider.select((s) => s.moodSubtitle)
    );
    final mood = ref.watch(
      dashboardControllerProvider.select((s) => s.mood)
    );
    final moodIconKey = ref.watch(
      dashboardControllerProvider.select((s) => s.moodIconKey)
    );
    final quoteText = ref.watch(
      dashboardControllerProvider.select((s) => s.quoteText)
    );
    final quoteSource = ref.watch(
      dashboardControllerProvider.select((s) => s.quoteSource)
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

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

              SizedBox(height: AlmaSpacing.lg),

              DashboardGreeting(
                userName: userName ?? "Usuario",
                archetype: archetype,
              ),

              SizedBox(height: AlmaSpacing.sectionR(context)),

              DashboardSection(
                child: DashboardFeatureGrid(
                  userId: userId!,
                  archetype: archetype,
                  painNodes: painNodes,
                ),
              ),

              SizedBox(height: AlmaSpacing.sectionR(context)),

              DashboardMoodCard(
                title: moodTitle,
                subtitle: moodSubtitle,
                mood: mood,
                icon: Icon(
                  MoodIconMapper.fromKey(moodIconKey),
                  color: AlmaColors.accent(isDark),
                ),
                onTap: () {},
              ),

              SizedBox(height: AlmaSpacing.sectionR(context)),

              DashboardQuoteCard(
                quote: quoteText,
                author: quoteSource,
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
