import 'package:flutter/material.dart';

import 'package:alma_diary/features/dashboard/alma_navbar.dart';
import 'package:alma_diary/features/search/search_page.dart';
import 'package:alma_diary/features/journal/create_page.dart';
import 'package:alma_diary/features/notifications/notifications_page.dart';
import 'package:alma_diary/features/profile/profile_page.dart';
import 'package:alma_diary/features/dashboard/dashboard_home.dart';
import 'package:alma_diary/services/supabase_service.dart';
import 'package:alma_diary/features/notifications/controller/notifications_controller.dart';

class AlmaDashboard extends StatefulWidget {
  const AlmaDashboard({super.key, required this.profile});
  final Map<String, dynamic>? profile;

  @override
  State<AlmaDashboard> createState() => _AlmaDashboardState();
}

class _AlmaDashboardState extends State<AlmaDashboard> {
  int _currentIndex = 0;
  bool _loading = true;

  String? _userId;
  String _archetype = 'The Self';
  List<String> _painNodes = [];

  final String passphrase = 'alma_biometric_pass';

  final _notificationController = NotificationController.instance;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = SupabaseService.instance.client.auth.currentUser;

    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    final profile = await SupabaseService.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (!mounted) return;

    _userId = user.id;

    // 🔥 init notifications once at app level
    _notificationController.setUserId(user.id);
    await _notificationController.load();

    setState(() {
      _archetype = profile?['archetype'] ?? 'The Self';
      _painNodes = List<String>.from(profile?['pain_nodes'] ?? []);
      _loading = false;
    });
  }

  List<Widget> get _pages {
    if (_userId == null) return [];

    return [
      DashboardHome(
        userId: _userId!,
        archetype: _archetype,
        painNodes: _painNodes,
        profile: widget.profile,
      ),
      SearchPage(
        passphrase: passphrase,
      ),
      const CreatePage(),
      const NotificationsPage(),
      const ProfilePage(),
    ];
  }

  void _onTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = _pages;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex.clamp(0, pages.length - 1),
        children: pages,
      ),
      bottomNavigationBar: AlmaNavbar(
        currentIndex: _currentIndex,
        onTap: _onTab,
      ),
    );
  }
}