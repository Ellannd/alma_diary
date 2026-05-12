import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alma_diary/features/notifications/controller/notifications_controller_old.dart';

class AlmaNavbar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AlmaNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<AlmaNavbar> createState() => _AlmaNavbarState();
}

class _AlmaNavbarState extends State<AlmaNavbar> {
  final _controller = NotificationController.instance;

  @override
  void initState() {
    super.initState();
    _init();
    _controller.addListener(_onUpdate);
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _init() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    _controller.setUserId(userId);
    await _controller.load();
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    super.dispose();
  }

  /// Badge dinámico basado en controller (single source of truth)
  Widget _buildNotificationIcon() {
    final unreadCount = _controller.unreadCount;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_outlined),

        if (unreadCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 14,
                minHeight: 14,
              ),
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _handleTap(int index) async {
    widget.onTap(index);

    ///  refresco controlado vía controller (no engine, no state local)
    if (index == 3) {
      await _controller.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: _handleTap,
      type: BottomNavigationBarType.fixed,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Buscar',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Nuevo',
        ),
        BottomNavigationBarItem(
          icon: _buildNotificationIcon(),
          label: 'Notifs',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Perfil',
        ),
      ],
    );
  }
}