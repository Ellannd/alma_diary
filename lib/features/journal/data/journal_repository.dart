import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alma_diary/services/supabase_service.dart';
import 'package:alma_diary/core/logging/log_service.dart';

/// JournalRepository - DATA LAYER
/// Handles all database operations for journal entries.
/// No encryption logic here - pure data operations.
class JournalRepository {
  static final JournalRepository instance = JournalRepository._();
  JournalRepository._();

  final SupabaseClient _client = SupabaseService.instance.client;

  User? get currentUser => _client.auth.currentUser;

  // =========================
  // INSERT ENTRY
  // =========================
  Future<void> insertEntry(Map<String, dynamic> entry) async {
    final userId = currentUser?.id;
    if (userId == null) {
      throw Exception('No hay usuario autenticado');
    }

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
        'updated_at': entry['updated_at'] ?? DateTime.now().toIso8601String(),
      }, onConflict: 'id');

      LogService.instance.info(
        'journal.entry_inserted',
        context: {'entry_id': entry['id'], 'user_id': userId},
      );
    } catch (e, st) {
      LogService.instance.error(
        'journal.insert_failed',
        error: e,
        stackTrace: st,
        context: {'user_id': userId},
      );
      rethrow;
    }
  }

  // =========================
  // GET ALL ENTRIES
  // =========================
  Future<List<Map<String, dynamic>>> getEntries() async {
    final userId = currentUser?.id;
    if (userId == null) {
      return [];
    }

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

  // =========================
  // GET ENTRY BY ID
  // =========================
  Future<Map<String, dynamic>?> getEntryById(String entryId) async {
    final userId = currentUser?.id;
    if (userId == null) {
      return null;
    }

    try {
      final response = await _client
          .from('journal_entries')
          .select()
          .eq('id', entryId)
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e, st) {
      LogService.instance.error(
        'journal.fetch_by_id_failed',
        error: e,
        stackTrace: st,
        context: {'entry_id': entryId, 'user_id': userId},
      );
      return null;
    }
  }

  // =========================
  // UPDATE ENTRY
  // =========================
  Future<void> updateEntry(String entryId, Map<String, dynamic> entry) async {
    final userId = currentUser?.id;
    if (userId == null) {
      throw Exception('No hay usuario autenticado');
    }

    try {
      await _client.from('journal_entries').upsert({
        'id': entryId,
        'user_id': userId,
        'content_encrypted': entry['content_encrypted'],
        'analysis_encrypted': entry['analysis_encrypted'],
        'sentiment': entry['sentiment'],
        'sentiment_score': entry['sentiment_score'],
        'archetype': entry['archetype'],
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id');

      LogService.instance.info(
        'journal.entry_updated',
        context: {'entry_id': entryId, 'user_id': userId},
      );
    } catch (e, st) {
      LogService.instance.error(
        'journal.update_failed',
        error: e,
        stackTrace: st,
        context: {'entry_id': entryId, 'user_id': userId},
      );
      rethrow;
    }
  }

  // =========================
  // DELETE ENTRY
  // =========================
  Future<void> deleteEntry(String entryId) async {
    final userId = currentUser?.id;
    if (userId == null) {
      throw Exception('No hay usuario autenticado');
    }

    try {
      await _client
          .from('journal_entries')
          .delete()
          .eq('id', entryId)
          .eq('user_id', userId);

      LogService.instance.info(
        'journal.entry_deleted',
        context: {'entry_id': entryId, 'user_id': userId},
      );
    } catch (e, st) {
      LogService.instance.error(
        'journal.delete_failed',
        error: e,
        stackTrace: st,
        context: {'entry_id': entryId, 'user_id': userId},
      );
      rethrow;
    }
  }
}
