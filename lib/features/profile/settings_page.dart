import 'package:flutter/material.dart';
import '../../core/logging/log_service.dart';
import '../../services/supabase_service.dart';
import '../../features/profile/data/profile_repository.dart';
import 'package:share_plus/share_plus.dart';
import "package:alma_diary/features/auth/auth_controller.dart";
import "package:alma_diary/features/profile/controller/profile_controller.dart";
import "package:alma_diary/features/notifications/controller/notifications_settings_controller.dart";

class SettingsPage extends StatefulWidget {

  final AuthController controller;
  final ProfileController profileController;
  final NotificationSettingsController notificationController;

  const SettingsPage({super.key, required this.controller, 
  required this.profileController,
  required this.notificationController,});



  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = widget.controller.currentUser;

    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final profile = await widget.profileController.loadProfile(user.id);

    widget.profileController.setContext(
      profile: profile,
      user: user,
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.controller.currentUser;

  if (user == null) {
    //TODO: Redirect to login
    return const SizedBox(); // o redirect
  }

  final String userId = user.id;

    final colorScheme = Theme.of(context).colorScheme;
    final onSurface = colorScheme.onSurface;
    final primary = colorScheme.primary;

    final name = widget.profileController.displayName;
    final email = widget.profileController.email;
    final avatar = widget.profileController.avatarUrl;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text('Ajustes'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: colorScheme.onPrimary,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!_isLoading) ...[
              Card(
                color: Theme.of(context).cardColor,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: primary,
                      backgroundImage: avatar != null
                      ? NetworkImage(avatar)
                      : null,
                          child: avatar == null
                  ? Text(
                      name.isNotEmpty
                          ? name[0].toUpperCase()
                          : 'U',
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : null,
                ),

                title: Text(
                  widget.profileController.displayName,
                  style: TextStyle(color: onSurface),
                ),

                subtitle: Text(
                  email,
                  style: TextStyle(
                    color: onSurface.withValues(alpha: .6),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
         Card(
          color: Theme.of(context).cardColor,
          child: SwitchListTile(
            secondary: Icon(Icons.notifications, color: primary),

            title: Text(
              'Recordatorio diario',
              style: TextStyle(color: onSurface),
            ),

            subtitle: Text(
              'Recibe un recordatorio para escribir',
              style: TextStyle(
                color: onSurface.withValues(alpha: .6),
              ),
            ),

            value: widget.notificationController.dailyReminderEnabled,
            

            onChanged: (value) async {
              await widget.notificationController.setDailyReminder(
                userId: userId,
                enabled: value,
              );
              LogService.instance.info("Daily Reminder: $value");
            },
          ),
        ),

           const SizedBox(height: 8),

          Card(
            color: Theme.of(context).cardColor,
            child: ListTile(
              leading: Icon(Icons.bug_report, color: primary),

              title: Text(
                'Enviar Reporte de Error',
                style: TextStyle(color: onSurface),
              ),

              subtitle: Text(
                'Comparte los logs de errores',
                style: TextStyle(
                  color: onSurface.withValues(alpha: .6),
                ),
              ),

              onTap: () => _sendErrorReport(context),
            ),
          ),

          const SizedBox(height: 8),

          Card(
            color: Theme.of(context).cardColor,
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),

              title: Text(
                'Limpiar Crash Log',
                style: TextStyle(color: onSurface),
              ),

              subtitle: Text(
                'Eliminar archivo de errores',
                style: TextStyle(
                  color: onSurface.withValues(alpha: .6),
                ),
              ),

              onTap: () => _clearCrashLog(context),
            ),
          ),

          const SizedBox(height: 24),

          if (widget.profileController.isAuthenticated)
            Card(
              color: Theme.of(context).cardColor,
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.orange),

                title: Text(
                  'Cerrar Sesión',
                  style: TextStyle(color: onSurface),
                ),

                onTap: () => _signOut(context),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _sendErrorReport(BuildContext context) async {
    try {

    final fullLog = LogService.instance.getFullLog();

      if (fullLog.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay logs de error disponibles')),
          );
        }
        return;
      }

      final report = '''
=== Alma Diary - Reporte de Error ===
Fecha: ${DateTime.now().toIso8601String()}
Usuario: ${SupabaseService.instance.currentUser?.email ?? 'No autenticado'}

--- Log Completo ---
$fullLog
''';

      await Share.share(
        report,
        subject: 'Alma Diary - Reporte de Error',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al preparar reporte: $e')),
        );
      }
    }
  }

  Future<void> _clearCrashLog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar Crash Log'),
        content: const Text('¿Estás seguro de que quieres eliminar el archivo de errores?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
       await LogService.instance.clear();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logs eliminados')),
        );
      }
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );

    if (confirm == true) {

      await widget.controller.logout();

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }
}
