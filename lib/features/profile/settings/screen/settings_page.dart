import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/state/auth/auth_controller.dart';
import 'package:alma_diary/state/profile/profile_controller.dart';
import 'package:alma_diary/state/notifications/notification_settings_controller.dart';

import 'package:alma_diary/features/profile/settings/widgets/settings_profile_card.dart';
import 'package:alma_diary/features/profile/presentation/widgets/profile_theme_switch.dart';
import 'package:alma_diary/features/profile/settings/widgets/settings_notifications_tile.dart';
import 'package:alma_diary/features/profile/settings/widgets/settings_report_tile.dart';
import 'package:alma_diary/features/profile/settings/widgets/settings_clear_logs_tile.dart';
import 'package:alma_diary/features/profile/settings/widgets/settings_logout_tile.dart';
import 'package:alma_diary/design_system/components/feedback/alma_feedback.dart';

class SettingsPage extends ConsumerStatefulWidget {
  final AuthController controller;
  final ProfileController profileController;
  final NotificationSettingsController notificationController;

  const SettingsPage({
    super.key,
    required this.controller,
    required this.profileController,
    required this.notificationController,
  });

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final user = widget.controller.currentUser;

      if (user != null) {
        await ref
            .read(profileControllerProvider.notifier)
            .loadProfile(user.id);
      }
    } catch (e) {
      LogService.instance.error('settings.load_failed', error: e);
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  //todo UI reaccione al estado de auth, no que fuerce navegación. sin navegación manual
  Future<void> _signOut() async {
    await ref.read(authControllerProvider.notifier).signOut();

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
  }

  Future<void> _sendReport() async {
    try {
      final logs = LogService.instance.getFullLog();

      if (logs.isEmpty) {
        AlmaFeedbackHelper.info('No hay logs disponibles');
        return;
      }

      await Share.share(
        logs.toString(),
        subject: 'Alma Diary - Reporte de Error',
      );

      AlmaFeedbackHelper.success('Reporte preparado');
    } catch (e) {
      LogService.instance.error('settings.share_failed', error: e);

      if (context.mounted) {
        AlmaFeedbackHelper.error('Error al generar el reporte');
      }
    }
  }

  Future<void> _clearLogs() async {
    await LogService.instance.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logs eliminados')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    final profileState = ref.watch(profileControllerProvider);
    final profile = profileState.profile;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No autenticado')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SettingsProfileCard(
                  name: widget.profileController.displayName,
                  email: widget.profileController.email,
                  avatarUrl: widget.profileController.avatarUrl,
                ),

                const SizedBox(height: 16),

                ProfileThemeSwitch(
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (v) {
                    // ThemeController si lo conectas
                  },
                ),

                const SizedBox(height: 12),

                SettingsNotificationsTile(
                  title: 'Recordatorio diario',
                  subtitle: 'Recibe un recordatorio para escribir',
                  value:
                      widget.notificationController.dailyReminderEnabled,
                  onChanged: (v) async {
                    await widget.notificationController.setDailyReminder(
                      userId: user.id,
                      enabled: v,
                    );
                  },
                ),

                const SizedBox(height: 12),

                SettingsReportTile(
                  title: 'Enviar reporte de error',
                  subtitle: 'Comparte logs del sistema',
                  onTap: _sendReport,
                ),

                const SizedBox(height: 12),

                SettingsClearLogsTile(
                  title: 'Limpiar logs',
                  subtitle: 'Eliminar historial de errores local',
                  onTap: _clearLogs,
                ),

                const SizedBox(height: 24),

                SettingsLogoutTile(
                  title: 'Cerrar sesión',
                  subtitle: 'Salir de tu cuenta',
                  onTap: _signOut,
                ),
              ],
            ),
    );
  }
}