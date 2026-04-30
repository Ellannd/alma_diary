import 'package:alma_diary/features/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:alma_diary/services/supabase_service.dart';
import 'package:alma_diary/features/profile/data/profile_repository.dart';
import "../../ai/engines/notifications_engine.dart";
import 'alma_theme.dart';
import '../readings/alma_readings.dart';
import '../reflections/alma_reflections.dart';
import '../reflections/alma_trajectory.dart';
import '../ai/challenges/alma_challenges.dart';
import '../ai/quotes/alma_quotes.dart';
import 'dashboard_card.dart';

class DashboardHome extends StatefulWidget {
  final String userId;
  final String archetype;
  final List<String> painNodes;

  const DashboardHome({
    super.key,
    required this.userId,
    required this.archetype,
    required this.painNodes,
  });

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  bool _quoteGenerated = false;
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

  Future<void> _initializeProfile() async {
    final user = SupabaseService.instance.client.auth.currentUser;
    
    // Properly await the async loadProfile call
    final profile = await _profileController.loadProfile(widget.userId);

    _profileController.setContext(
      profile: profile,
      user: user,
    );

    _generateDailyQuoteOnce();
  }

  Future<void> _generateDailyQuoteOnce() async {
    if (_quoteGenerated) return;

    final user = SupabaseService.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final engine = AlmaNotificationEngine(SupabaseService.instance.client);

      await engine.generateDailyQuote(user.id);

      _quoteGenerated = true;
    } catch (e) {
      debugPrint('Error generando quote diaria: $e');
    }
  }

@override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();
    final userName = _profileController.firstName;

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
                      color: AlmaTheme.accent,
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
