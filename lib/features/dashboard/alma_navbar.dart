import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alma_diary/ai/engines/notifications_engine.dart';

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
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final engine = AlmaNotificationEngine(Supabase.instance.client);
    final count = await engine.getUnreadCount(userId);

    if (!mounted) return;

    setState(() => _unreadCount = count);
  }

  /// 🔴 Badge dinámico
  Widget _buildNotificationIcon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_outlined),

        if (_unreadCount > 0)
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
                _unreadCount > 9 ? '9+' : '$_unreadCount',
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

    /// 🔄 refresco inteligente del badge
    if (index == 3) {
      await Future.delayed(const Duration(milliseconds: 300));
      _loadUnreadCount();
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

        /// 🔥 SEARCH (IMPORTANTE: este es el fix conceptual)
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