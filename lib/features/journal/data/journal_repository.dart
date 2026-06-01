import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alma_diary/services/supabase_service.dart';
import 'package:alma_diary/core/logging/log_service.dart';

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
  if (userId == null) throw Exception('No hay usuario autenticado');

  try {
    await _client.from('journal_entries').upsert({
      'id': entry['id'],
      'user_id': userId,
      'title': entry['title'] ?? '',
      'content_v2': entry['content_v2'],
      'analysis_v2': entry['analysis_v2'],
      'sentiment': entry['sentiment'],
      'sentiment_score': entry['sentiment_score'],
      'archetype': entry['archetype'],
      'created_at': entry['created_at'] ?? DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
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

  // =========================
  // GET ENTRY BY ID
  // =========================
  Future<Map<String, dynamic>?> getEntryById(String entryId) async {
    final userId = currentUser?.id;
    if (userId == null) return null;

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
    if (userId == null) throw Exception('No hay usuario autenticado');

    try {
      // Construir el map solo con los campos que vienen — update parcial
      final updateMap = <String, dynamic>{
        'id': entryId,
        'user_id': userId,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (entry.containsKey('title')) updateMap['title'] = entry['title'];
      
      // v2
      if (entry.containsKey('content_v2')) {
        updateMap['content_v2'] = entry['content_v2'];
        updateMap['content_encrypted'] = ''; // vaciar v1
      }
      if (entry.containsKey('analysis_v2')) {
        updateMap['analysis_v2'] = entry['analysis_v2'];
        updateMap['analysis_encrypted'] = ''; // vaciar v1
      }
      if (entry.containsKey('migrated')) {
        updateMap['migrated'] = entry['migrated'];
        updateMap['migrated_at'] = entry['migrated_at'];
      }

      // metadata
      if (entry.containsKey('sentiment')) updateMap['sentiment'] = entry['sentiment'];
      if (entry.containsKey('sentiment_score')) updateMap['sentiment_score'] = entry['sentiment_score'];
      if (entry.containsKey('archetype')) updateMap['archetype'] = entry['archetype'];

      await _client.from('journal_entries').upsert(
        updateMap,
        onConflict: 'id',
      );

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
    if (userId == null) throw Exception('No hay usuario autenticado');

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