import 'package:alma_diary/design_system/components/feedback/alma_loader.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';

import 'package:alma_diary/core/logging/log_service.dart';

import 'package:alma_diary/state/auth/auth_controller.dart';
import 'package:alma_diary/state/profile/profile_controller.dart';
import 'package:alma_diary/state/theme/theme_controller.dart';
import 'package:alma_diary/state/notifications/notification_settings_controller.dart';

import 'package:alma_diary/features/profile/settings/widgets/settings_profile_card.dart';
import 'package:alma_diary/features/profile/presentation/widgets/profile_theme_switch.dart';
import 'package:alma_diary/features/profile/settings/widgets/settings_notifications_tile.dart';
import 'package:alma_diary/features/profile/settings/widgets/settings_report_tile.dart';
import 'package:alma_diary/features/profile/settings/widgets/settings_clear_logs_tile.dart';
import 'package:alma_diary/features/profile/settings/widgets/settings_logout_tile.dart';
import 'package:alma_diary/features/debug/screen/log_viewer_page.dart';

import 'package:alma_diary/design_system/components/feedback/alma_feedback.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // El perfil ya está cargado via sessionProvider — solo apagamos el loading local.
    setState(() => _loading = false);
  }

  Future<void> _signOut() async {
    await ref.read(authControllerProvider.notifier).signOut();

    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (_) => false,
    );
  }

  Future<void> _sendReport() async {
  try {
    final logs = LogService.instance.getFullLog();

    if (logs.isEmpty) {
      AlmaFeedbackHelper.info('No hay logs disponibles');
      return;
    }

    // Limitar a los últimos 200 entries para no exceder el límite de Android
    final limited = logs.length > 200 ? logs.sublist(logs.length - 200) : logs;
    final text = limited.map((e) => e.toString()).join('\n');

    await Share.share(
      text,
      subject: 'Alma Diary - Reporte de Error',
    );

    AlmaFeedbackHelper.success('Reporte preparado');
  } catch (e) {
    LogService.instance.error('settings.share_failed', error: e);
    if (mounted) {
      AlmaFeedbackHelper.error('Error al generar el reporte');
    }
  }
}

  Future<void> _clearLogs() async {
    await LogService.instance.clear();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logs eliminados'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    final profile = ref.watch(profileControllerProvider.select((s) => s.value));
    final dailyReminder = ref.watch(
      notificationSettingsControllerProvider.select((s) => s.dailyReminderEnabled),
    );
    final isDark = ref.watch(
      themeControllerProvider.select((s) => s == AppThemeMode.dark),
  );


    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: _loading
          ? const Center(
              child: AlmaLoader(),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SettingsProfileCard(
                  name: profile?.displayName ?? 'Usuario',
                  email: profile?.email ?? user?.email ?? '',
                  avatarUrl: profile?.avatarUrl,
                ),

                const SizedBox(height: 16),

                ProfileThemeSwitch(
                  value: isDark,
                  onChanged: (_) {
                    ref
                        .read(themeControllerProvider.notifier)
                        .toggleTheme();
                  },
                ),

                const SizedBox(height: 12),

                SettingsNotificationsTile(
                  title: 'Recordatorio diario',
                  subtitle:
                      'Recibe un recordatorio para escribir',
                  value:
                      dailyReminder,
                  onChanged: (enabled) async {
                    await ref
                        .read(
                          notificationSettingsControllerProvider
                              .notifier,
                        )
                        .setDailyReminder(
                          userId: user?.id,
                          enabled: enabled,
                        );
                  },
                ),

              SizedBox(height: AlmaSpacing.r(context, 12)),

                SettingsReportTile(
                  title: 'Enviar reporte de error',
                  subtitle: 'Comparte logs del sistema',
                  onTap: _sendReport,
                ),

                SizedBox(height: AlmaSpacing.r(context, 12)),

                SettingsClearLogsTile(
                  title: 'Limpiar logs',
                  subtitle:
                      'Eliminar historial de errores local',
                  onTap: _clearLogs,
                ),

                SizedBox(height: AlmaSpacing.r(context, 12)),

                SettingsLogoutTile(
                  title: 'Cerrar sesión',
                  subtitle: 'Salir de tu cuenta',
                  onTap: _signOut,
                ),

                if (kDebugMode) ...[
                  SizedBox(height: AlmaSpacing.r(context, 12)),
                  ListTile(
                    leading: const Icon(Icons.bug_report_outlined),
                    title: const Text('Dev Console'),
                    subtitle: const Text('Logs internos del sistema'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LogViewerPage()),
                    ),
                  ),
                ],
              ],   
            ),
    );
  }
}
