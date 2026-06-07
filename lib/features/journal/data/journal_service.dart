import 'package:alma_diary/core/crypto/local_key_service.dart';
import 'package:alma_diary/state/journal/domain/journal_entry_model.dart';
import 'package:uuid/uuid.dart';
import 'package:alma_diary/core/crypto/crypto_provider.dart';
import 'package:alma_diary/features/journal/data/journal_repository.dart';
import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/ai/analysis/ai_services_impl.dart';
import 'package:alma_diary/ai/analysis/providers/gemini_provider.dart';
import 'package:alma_diary/ai/analysis/providers/huggingface_provider.dart';
import 'package:alma_diary/ai/analysis/providers/mock_provider.dart';
import 'package:alma_diary/ai/analysis/router/model_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class JournalService {
  static final JournalService instance = JournalService._();
  JournalService._();

  final _repository = JournalRepository.instance;
  final _uuid = const Uuid();

  // CryptoSession se inyecta en el primer uso — evita acceder a
  // Riverpod desde un singleton estático.
  CryptoSession? _crypto;

  /// Llamar desde el controller justo después de que CryptoSession
  /// esté inicializada (post-login), antes del primer acceso al journal.
  void setCryptoSession(CryptoSession session) {
    _crypto = session;
  }

  // CryptoSession get _session {
  //   final s = _crypto;
  //   if (s == null) {
  //     throw StateError(
  //       'JournalService: CryptoSession not set. '
  //       'Call setCryptoSession() after login.',
  //     );
  //   }
  //   return s;
  // }

  Future<CryptoSession> _getSession() async {
    if (_crypto != null) return _crypto!;

    // Intentar reconstruir sesión desde Keychain sin red
    // (puede pasar si JournalService se llama antes de setCryptoSession)
    final storage = SecureStorageService();
    final keyResult = await storage.loadKey();

    if (keyResult is StorageReadSuccess) {
      final session = CryptoSession(
        localKey: LocalKeyService(storage: storage),
        encryption: EncryptionService(),
        storage: storage,
      );
      _crypto = session;
      return session;
    }

    throw StateError(
      'JournalService: CryptoSession not set and no key in storage. '
      'Call setCryptoSession() after login.',
    );
  }

  final aiService = AIServiceImpl(
    router: ModelRouter(
      mock: MockProvider(),
      huggingface: HuggingFaceProvider(),
    ),
  );

  // ──────────────────────────────────────────────────────────
  // ENCRYPTION — V2 (GCM)
  // ──────────────────────────────────────────────────────────

  Future<String> _encryptV2(String plaintext) async {
    final session = await _getSession();
    final result = await session.encryptText(plaintext);
    if (result is EncryptSuccess) return result.bundle.serialize();

    final failure = result as EncryptFailure;
    LogService.instance.error(
      'journal.encrypt_v2_detail',
      context: {
        'message': failure.message,
        'cause': failure.cause?.toString() ?? 'null',
        'cause_type': failure.cause?.runtimeType.toString() ?? 'null',
      },
    );
    throw StateError('JournalService: encryption failed — ${failure.message}');
  }

  Future<String> _decryptV2(String serialized) async {
    if (serialized.isEmpty) return '';
    final session = await _getSession();
    final result = await session.decryptText(serialized);
    if (result is DecryptSuccess) return result.plaintext;
    LogService.instance.error(
      'journal.decrypt_v2_failed',
      context: {'reason': (result as DecryptFailure).message},
    );
    return '';
  }

  // ──────────────────────────────────────────────────────────
  // DECODE HELPERS — elige v2 o v1 según el flag migrated
  // ──────────────────────────────────────────────────────────
  Future<String> _decryptContent(Map<String, dynamic> row) async {
    return _decryptV2(row['content_v2'] as String? ?? '');
  }

  Future<String> _decryptAnalysis(Map<String, dynamic> row) async {
    return _decryptV2(row['analysis_v2'] as String? ?? '');
  }
  // ──────────────────────────────────────────────────────────
  // ANALYSIS (Gemini)
  // ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> analyzeEntry(String content) async {
    try {
      final analysis = await aiService.analyze(content);
      return {
        'sentiment': analysis.sentiment,
        'sentimentScore': analysis.sentimentScore,
        'archetype': analysis.archetype,
        'reflection': analysis.reflection,
      };
    } catch (e, st) {
      LogService.instance.error(
        'journal.gemini_analysis_failed',
        error: e,
        stackTrace: st,
      );
      return {
        'sentiment': 'neutral',
        'sentimentScore': 0.5,
        'archetype': 'The Mirror',
        'reflection': 'Tu experiencia es válida y merece atención.',
      };
    }
  }

  // ──────────────────────────────────────────────────────────
  // COMBINED — análisis + guardado
  // ──────────────────────────────────────────────────────────

  Future<
    ({String entryId, String archetype, String sentiment, String plainContent})
  >
  createEntryWithAnalysis({required String content, String? title}) async {
    final analysis = await analyzeEntry(content);
    final result = await createEntry(
      content: content,
      title: title,
      sentiment: analysis['sentiment'] as String,
      sentimentScore: analysis['sentimentScore'] as double,
      archetype: analysis['archetype'] as String,
      reflection: analysis['reflection'] as String,
    );
    return (
      entryId: result.entryId,
      archetype: result.archetype,
      sentiment: result.sentiment,
      plainContent: content, // texto plano antes de cifrar
    );
  }
  // ──────────────────────────────────────────────────────────
  // CRUD
  // ──────────────────────────────────────────────────────────

  /// Crea una entrada nueva. Siempre cifra con v2 (GCM).
  /// Las columnas v1 se dejan null — el repositorio las ignora si no van
  /// en el map.
  Future<({String entryId, String archetype, String sentiment})> createEntry({
    required String content,
    required String sentiment,
    required double sentimentScore,
    required String archetype,
    required String reflection,
    String? title, // parámetro opcional
  }) async {
    final entryId = _uuid.v4();
    final now = DateTime.now();

    final encContent = await _encryptV2(content);
    final encAnalysis = await _encryptV2(reflection);

    await _repository.insertEntry({
      'id': entryId,
      'title': title?.trim().isNotEmpty == true
          ? title!.trim()
          : JournalEntryModel.defaultTitle(now), // fallback fecha
      'content_v2': encContent,
      'analysis_v2': encAnalysis,
      'sentiment': sentiment,
      'sentiment_score': sentimentScore,
      'archetype': archetype,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });

    return (entryId: entryId, archetype: archetype, sentiment: sentiment);
  }

  Future<List<Map<String, dynamic>>> getEntries({bool decrypt = true}) async {
    final rows = await _repository.getEntries();
    if (!decrypt) return rows;

    final result = <Map<String, dynamic>>[];
    for (final row in rows) {
      result.add({
        ...row,
        'content_decrypted': await _decryptContent(row),
        'analysis_decrypted': await _decryptAnalysis(row),
      });
    }
    return result;
  }

  Future<Map<String, dynamic>?> getEntryById(
    String entryId, {
    bool decrypt = true,
  }) async {
    final row = await _repository.getEntryById(entryId);
    if (row == null) return null;
    if (!decrypt) return row;

    return {
      ...row,
      'content_decrypted': await _decryptContent(row),
      'analysis_decrypted': await _decryptAnalysis(row),
    };
  }

  /// Actualiza una entrada. Siempre re-cifra con v2 y marca migrated=true,
  /// por si la entrada actualizada era aún v1.
  Future<void> updateEntry({
    required String entryId,
    String? content,
    String? title,
    String? reflection,
    String? sentiment,
    double? sentimentScore,
    String? archetype,
  }) async {
    final entryMap = <String, dynamic>{};

    if (title != null)
      entryMap['title'] =
          title; //no se cifra el título, se actualiza directamente
    if (content != null) entryMap['content_v2'] = await _encryptV2(content);
    if (reflection != null)
      entryMap['analysis_v2'] = await _encryptV2(reflection);
    if (sentiment != null) entryMap['sentiment'] = sentiment;
    if (sentimentScore != null) entryMap['sentiment_score'] = sentimentScore;
    if (archetype != null) entryMap['archetype'] = archetype;

    entryMap['updated_at'] = DateTime.now().toUtc().toIso8601String();

    await _repository.updateEntry(entryId, entryMap);
  }

  Future<void> deleteEntry(String entryId) async {
    await _repository.deleteEntry(entryId);
  }

  // ──────────────────────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────────────────────

  String generateEntryId() => _uuid.v4();
  String generateTimestamp() => DateTime.now().toIso8601String();
}
