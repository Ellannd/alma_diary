import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/features/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:alma_diary/services/supabase_service.dart';
import 'package:alma_diary/features/profile/data/profile_repository.dart';
import 'package:alma_diary/features/notifications/controller/notifications_controller.dart';
import 'package:alma_diary/features/readings/alma_readings.dart';
import 'package:alma_diary/features/reflections/alma_reflections.dart';
import 'package:alma_diary/features/reflections/alma_trajectory.dart';
import 'package:alma_diary/features/ai/challenges/alma_challenges.dart';
import 'package:alma_diary/features/ai/quotes/alma_quotes.dart';
import 'dashboard_card.dart';
import "package:firebase_messaging/firebase_messaging.dart";
import "package:firebase_core/firebase_core.dart";
import "package:alma_diary/firebase_options.dart";

class DashboardHome extends StatefulWidget {
  final String userId;
  final String archetype;
  final List<String> painNodes;
  final Map<String, dynamic>? profile;
  final VoidCallback? onRouteConsumed;
  final ValueChanged<int>? onNavigateToTab;
  final routeEvent;
  
  const DashboardHome({
    super.key,
    required this.userId,
    required this.archetype,
    required this.painNodes,
    required this.profile,
    this.onRouteConsumed,
    this.routeEvent,
    this.onNavigateToTab
  });

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  bool _quoteGenerated = false;
  bool _profileLoaded = false;
  late final ProfileController _profileController;


  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

@override
  void initState() {
    super.initState();

    _profileController = ProfileController(ProfileRepository());

    _initializeProfile();
  }


@override
void didUpdateWidget(covariant DashboardHome oldWidget) {
  super.didUpdateWidget(oldWidget);

  if (widget.routeEvent != null &&
      widget.routeEvent != oldWidget.routeEvent) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleDeepLink(widget.routeEvent!);

      // IMPORTANTÍSIMO: limpiar en el siguiente frame
      widget.onRouteConsumed?.call();
    });
  }
}


  void _handleDeepLink(String route) {
    debugPrint('Deep link to: $route');

    switch (route) {
      case '/challenges':
        widget.onNavigateToTab?.call(1);
        break;

      case '/trajectory':
        widget.onNavigateToTab?.call(1);
        break;
    }
  }

  Future<void> _initializeProfile() async {
    final user = SupabaseService.instance.client.auth.currentUser;
    
    // Properly await the async loadProfile call
    final profile = await _profileController.loadProfile(widget.userId);

    _profileController.setContext(
      profile: profile,
      user: user,
    );

    // Trigger rebuild to display loaded user name
    if (mounted) {
      setState(() {
        _profileLoaded = true;
      });
    }

    _generateDailyQuoteOnce();
  }

  /// Get user name from ProfileController (single source of truth)
  /// This ensures consistent name display across both Google Auth and Email/Password
  String _getUserName() {
    // ProfileController.displayName already handles fallback chain:
    // profile.full_name -> user.userMetadata['name'] -> email -> 'Usuario'
    return _profileController.displayName;
  }

Future<void> _generateDailyQuoteOnce() async {
    if (_quoteGenerated) return;

    final user = SupabaseService.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await NotificationController.instance.handlePostLogin(user.id);
      _quoteGenerated = true;
    } catch (e) {
      debugPrint('Error generando quote diaria: $e');
    }
  }

@override
  Widget build(BuildContext context) {

    final greeting = _getGreeting();
    final userName = _getUserName();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shield_moon,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting, $userName',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.archetype,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // GRID
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  DashboardCard(
                    icon: Icons.edit,
                    label: 'Diario',
                    onTap: () {
                      Navigator.of(context).pushNamed('/journal');
                    },
                  ),
                  DashboardCard(
                    icon: Icons.psychology,
                    label: 'Reflexiones',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AlmaReflectionsScreen(
                            passphrase: 'alma_biometric_pass',
                          ),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Icons.auto_stories,
                    label: 'Lecturas',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AlmaReadingsScreen(
                            userId: widget.userId,
                            passphrase: 'alma_biometric_pass',
                          ),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Icons.trending_up,
                    label: 'Trayectoria',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AlmaTrajectoryScreen(
                            passphrase: 'alma_biometric_pass',
                          ),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Icons.emoji_events,
                    label: 'Desafíos',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AlmaChallengesScreen(
                            passphrase: 'alma_biometric_pass',
                          ),
                        ),
                      );
                    },
                  ),
                  DashboardCard(
                    icon: Icons.format_quote,
                    label: 'Citas',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AlmaQuotesScreen(
                            arquetipo: widget.archetype,
                            nodosDolor: widget.painNodes,
                          ),
                        ),
                      );
                    },
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
