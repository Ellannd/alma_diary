// notification_settings_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alma_diary/services/supabase_service.dart';

import 'notification_settings_state.dart';

final notificationSettingsControllerProvider =
    NotifierProvider<
        NotificationSettingsController,
        NotificationSettingsState>(
  NotificationSettingsController.new,
);

class NotificationSettingsController
    extends Notifier<NotificationSettingsState> {
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
    state = state.copyWith(
      loading: true,
      clearError: true,
    );

    try {
      final data = await _client
          .from('notification_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      state = state.copyWith(
        loading: false,
        dailyReminderEnabled:
            data?['daily_reminder_enabled'] ?? false,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error:
            'No se pudieron cargar las preferencias',
      );
    }
  }

  // =========================
  // DAILY REMINDER
  // =========================

  Future<void> setDailyReminder({
    required String userId,
    required bool enabled,
  }) async {
    state = state.copyWith(
      saving: true,
      clearError: true,
    );

    try {
      await _client
          .from('notification_settings')
          .upsert({
        'user_id': userId,
        'daily_reminder_enabled': enabled,
      });

      state = state.copyWith(
        saving: false,
        dailyReminderEnabled: enabled,
      );
    } catch (e) {
      state = state.copyWith(
        saving: false,
        error:
            'No se pudo actualizar la preferencia',
      );
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