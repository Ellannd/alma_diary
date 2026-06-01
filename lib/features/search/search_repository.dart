import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alma_diary/core/crypto/crypto_provider.dart';

class SearchRepository {
  final SupabaseClient client = Supabase.instance.client;
  final CryptoSession crypto;

  SearchRepository({required this.crypto});

  Future<List<Map<String, dynamic>>> getJournal(String userId) async {
    final rows = await client
        .from('journal_entries')
        .select('id, title, content_v2, analysis_v2, sentiment, archetype, created_at')
        .eq('user_id', userId);

    final decrypted = <Map<String, dynamic>>[];

    for (final row in rows) {
      final contentResult = await crypto.decryptText(row['content_v2'] ?? '');
      final analysisResult = await crypto.decryptText(row['analysis_v2'] ?? '');

      decrypted.add({
        ...row,
        'type': 'journal',
        'content_decrypted': contentResult is DecryptSuccess
            ? contentResult.plaintext
            : '',
        'analysis_decrypted': analysisResult is DecryptSuccess
            ? analysisResult.plaintext
            : '',
      });
    }

    return decrypted;
  }

  Future<List<Map<String, dynamic>>> getReflections(String userId) async {
    // Actualmente reflections == journal entries con analysis_v2
    // Cuando las separes en su propia tabla, actualizas aquí
    return getJournal(userId);
  }

  Future<List<Map<String, dynamic>>> getChallenges(String userId) async {
    return await client
        .from('user_challenges')
        .select('*, challenges(*)')
        .eq('user_id', userId);
  }

  Future<List<Map<String, dynamic>>> getQuotes() async {
    return await client
        .from('quotes')
        .select('id, title, text, author, tags');
  }
}