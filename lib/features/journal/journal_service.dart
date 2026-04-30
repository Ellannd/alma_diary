import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../data/aes_encryption.dart';

class JournalService {
  static final JournalService instance = JournalService._();
  JournalService._();

  final _client = Supabase.instance.client;
  //TODO: generar una key para cada usuario
  static const _passphrase = 'alma_biometric_pass';

  Future<void> createEntry({
    required String content,
    required String sentiment,
    required double sentimentScore,
    required String archetype,
    required String reflection,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final now = DateTime.now().toIso8601String();

    // CIFRADO REAL
    final encryptedContent =
        AESEncryption.encryptText(content, _passphrase);

    final encryptedAnalysis =
        AESEncryption.encryptText(reflection, _passphrase);

    final data = {
      'id': const Uuid().v4(),
      'user_id': user.id,
      'content_encrypted': encryptedContent,
      'analysis_encrypted': encryptedAnalysis,
      'sentiment': sentiment,
      'sentiment_score': sentimentScore,
      'archetype': archetype,
      'created_at': now,
      'updated_at': now,
    };

    await _client.from('journal_entries').insert(data);
  }

  Future<List<Map<String, dynamic>>> getEntries() async {
    final user = _client.auth.currentUser;

    if (user == null) return [];

    final response = await _client
        .from('journal_entries')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}