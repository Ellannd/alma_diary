import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alma_diary/services/supabase_service.dart';
import 'package:alma_diary/core/logging/log_service.dart';

class JournalRepository {
  final SupabaseClient _client = SupabaseService.instance.client;

  User? get currentUser => _client.auth.currentUser;

  // =========================
  // SAVE ENTRY
  // =========================
  Future<void> saveJournalEntry(Map<String, dynamic> entry) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('No hay usuario autenticado');

    try {
      await _client.from('journal_entries').upsert({
        'id': entry['id'],
        'user_id': userId,
        'content_encrypted': entry['content_encrypted'],
        'analysis_encrypted': entry['analysis_encrypted'],
        'sentiment': entry['sentiment'],
        'sentiment_score': entry['sentiment_score'],
        'archetype': entry['archetype'],
        'created_at': entry['created_at'] ?? DateTime.now().toIso8601String(),
      }, onConflict: 'id');

      LogService.instance.info(
        'journal.saved',
        context: {'user_id': userId},
      );
    } catch (e, st) {
      LogService.instance.error(
        'journal.save_failed',
        error: e,
        stackTrace: st,
        context: {'user_id': userId},
      );
      rethrow;
    }
  }

  // =========================
  // GET ENTRIES
  // =========================
  Future<List<Map<String, dynamic>>> getJournalEntries() async {
    final userId = currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('journal_entries')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e, st) {
      LogService.instance.error(
        'journal.fetch_failed',
        error: e,
        stackTrace: st,
        context: {'user_id': userId},
      );
      return [];
    }
  }
}