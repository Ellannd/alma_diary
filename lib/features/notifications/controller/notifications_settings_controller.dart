import 'package:flutter/foundation.dart';
import 'package:alma_diary/services/supabase_service.dart';

class NotificationSettingsController extends ChangeNotifier {
  final _client = SupabaseService.instance.client;

  bool _dailyReminderEnabled = false;

  bool get dailyReminderEnabled => _dailyReminderEnabled;

  Future<void> load(String userId) async {
    final data = await _client
        .from('notification_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    _dailyReminderEnabled = data?['daily_reminder_enabled'] ?? false;
    notifyListeners();
  }

  Future<void> setDailyReminder({
    required String userId,
    required bool enabled,
  }) async {
    await _client.from('notification_settings').upsert({
      'user_id': userId,
      'daily_reminder_enabled': enabled,
    });

    _dailyReminderEnabled = enabled;
    notifyListeners();
  }
}