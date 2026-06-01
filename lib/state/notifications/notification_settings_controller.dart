// notification_settings_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alma_diary/services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_settings_state.dart';

final notificationSettingsControllerProvider =
    NotifierProvider<
        NotificationSettingsController,
        NotificationSettingsState>(
  NotificationSettingsController.new,
);

class NotificationSettingsController
    extends Notifier<NotificationSettingsState> {

  static const _kDailyReminder = 'daily_reminder_enabled';

  late final dynamic _client;

  @override
  NotificationSettingsState build() {
    _client = SupabaseService.instance.client;

    return NotificationSettingsState.initial();
  }

 // =========================
  // LOAD SETTINGS
  // =========================

  Future<void> load(String userId) async {
    // 1. Carga local primero — instantáneo, sin loading spinner
    final prefs = await SharedPreferences.getInstance();
    final localValue = prefs.getBool(_kDailyReminder);

    if (localValue != null) {
      state = state.copyWith(dailyReminderEnabled: localValue);
    }

    // 2. Sincroniza con Supabase en background
    try {
      final data = await _client
          .from('notification_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      final remoteValue = data?['daily_reminder_enabled'] as bool?;

      if (remoteValue != null && remoteValue != localValue) {
        // Supabase gana si difieren (otro dispositivo pudo cambiarla)
        await prefs.setBool(_kDailyReminder, remoteValue);
        state = state.copyWith(dailyReminderEnabled: remoteValue);
      }
    } catch (_) {
      // Sin internet: el valor local ya está aplicado, no pasa nada
    }
  }


  // =========================
  // DAILY REMINDER
  // =========================

  Future<void> setDailyReminder({
    required String? userId,
    required bool enabled,
  }) async {
    // 1. Guarda local inmediatamente — UI responde al instante
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDailyReminder, enabled);
    state = state.copyWith(dailyReminderEnabled: enabled);

    //  2. Sincroniza con Supabase en background
    if (userId == null) return;
    try {
      await _client
          .from('notification_settings')
          .upsert({'user_id': userId, 'daily_reminder_enabled': enabled});
    } catch (_) {
      // Falló el sync remoto — el valor local ya está guardado,
      // se sincronizará en el próximo load()
    }
  }

  // =========================
  // TOGGLE
  // =========================

  Future<void> toggleDailyReminder(
    String userId,
  ) async {
    final next =
        !state.dailyReminderEnabled;

    await setDailyReminder(
      userId: userId,
      enabled: next,
    );
  }

  // =========================
  // GETTERS (READ ONLY UI)
  // =========================

  bool get dailyReminderEnabled =>
      state.dailyReminderEnabled;

    // =========================
    // HELPERS
    // =========================

  void clearError() {
    state = state.copyWith(
      clearError: true,
    );
  }

  void reset() {
    state =
        NotificationSettingsState.initial();
  }
}