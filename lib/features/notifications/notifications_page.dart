import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alma_diary/models/alma_notification.dart';
import 'package:alma_diary/ai/engines/notifications_engine.dart';
import 'package:alma_diary/features/dashboard/alma_theme.dart';
import 'package:alma_diary/features/journal/create_page.dart';
import 'package:alma_diary/features/reflections/alma_trajectory.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _engine = AlmaNotificationEngine(Supabase.instance.client);

  List<AlmaNotification> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // -------------------------
  // LOAD NOTIFICATIONS
  // -------------------------
  Future<void> _loadNotifications() async {
    setState(() => _loading = true);

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final data = await _engine.fetchUserNotifications(userId);

      setState(() {
        _notifications = data.map((e) => AlmaNotification.fromMap(e)).toList();
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      setState(() => _loading = false);
    }
  }

  // -------------------------
  // MARK AS READ (OPTIMISTIC UI)
  // -------------------------
  Future<void> _markAsRead(AlmaNotification n) async {
    final index = _notifications.indexWhere((e) => e.id == n.id);
    if (index == -1) return;

    // UI update inmediato
    setState(() {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    });

    // DB update async
    await _engine.markAsRead(n.id);
  }

  // -------------------------
  // ICONS
  // -------------------------
  Color _getColor(String color) {
    switch (color) {
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'green':
        return Colors.green;
      case 'amber':
        return Colors.amber;
      default:
        return AlmaTheme.accent;
    }
  }

  IconData _getIcon(String icon) {
    switch (icon) {
      case 'schedule':
        return Icons.schedule;
      case 'psychology':
        return Icons.psychology;
      case 'emoji':
        return Icons.emoji_events;
      case 'dark':
        return Icons.dark_mode;
      default:
        return Icons.notifications;
    }
  }

  // -------------------------
  // ACTIONS
  // -------------------------
  void _handleAction(AlmaNotification n) {
    if (n.actionRoute != null) {
      Navigator.of(context).pushNamed(n.actionRoute!);
      return;
    }

    switch (n.action) {
      case 'Escribir ahora':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const CreatePage()));
        break;

      case 'Revisar trayectoria':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                const AlmaTrajectoryScreen(passphrase: 'alma_biometric_pass'),
          ),
        );
        break;

      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(n.action)));
    }
  }

  // -------------------------
  // UI
  // -------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Insights Alma'),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
          ? const Center(
              child: Text(
                'No hay notificaciones',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final n = _notifications[index];
                final color = _getColor(n.color);
                final icon = _getIcon(n.icon);

                final opacity = n.isRead ? 0.45 : 1.0;

                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: opacity,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),

                    onTap: () async {
                      await _markAsRead(n);
                      _handleAction(n);
                    },

                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: n.isRead ? 1 : 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(20),

                        leading: CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.2),
                          child: Icon(icon, color: color, size: 26),
                        ),

                        title: Text(
                          n.title,
                          style: TextStyle(
                            fontWeight: n.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),

                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            n.subtitle,
                            style: TextStyle(
                              height: 1.4,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ),

                        trailing: ElevatedButton(
                          onPressed: () async {
                            await _markAsRead(n);
                            _handleAction(n);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(n.action),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
