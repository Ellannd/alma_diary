import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'log_entry.dart';

class LogRepository {
  static const String _storageKey = 'alma_log_entries';

  Future<List<LogEntry>> loadLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);

      return jsonList
          .map((e) => LogEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveLogs(List<LogEntry> logs) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final jsonString = jsonEncode(
        logs.map((e) => e.toJson()).toList(),
      );

      await prefs.setString(_storageKey, jsonString);
    } catch (_) {
      // fail silent (logging system must never crash app)
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}