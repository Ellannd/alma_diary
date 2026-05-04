import 'package:uuid/uuid.dart';
import 'package:alma_diary/data/aes_encryption.dart';
import 'package:alma_diary/features/journal/data/journal_repository.dart';
import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/features/ai/analysis/ai_services_impl.dart';
import 'package:alma_diary/features/ai/analysis/providers/gemini_provider.dart';
import 'package:alma_diary/features/ai/analysis/providers/huggingface_provider.dart';
import 'package:alma_diary/features/ai/analysis/providers/mock_provider.dart';
import 'package:alma_diary/features/ai/analysis/router/model_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


/// JournalService - UTILITARIO LAYER
/// Handles pure utility functions:
/// - AES encrypt/decrypt (delegates to AESEncryption)
/// - UUID generation
/// - Data formatting helpers
/// - Gemini analysis integration
/// No database calls here - uses JournalRepository for data operations.
class JournalService {
  static final JournalService instance = JournalService._();
  JournalService._();

  static const String _passphrase = 'alma_biometric_pass';
  final _repository = JournalRepository.instance;
  final _uuid = const Uuid();
    final aiService = AIServiceImpl(
  router: ModelRouter(
    mock: MockProvider(),

    huggingface: HuggingFaceProvider(
      apiKey: dotenv.get('HF_API_KEY'),
    ),

    gemini: GeminiProvider(
      apiKey: dotenv.get('GEMINI_API_KEY'),
    ),
  ),
);

  // =========================
  // ENCRYPTION METHODS
  // =========================

  /// Encrypts journal content using AES
  String encryptContent(String content) {
    return AESEncryption.encryptText(content, _passphrase);
  }

  /// Decrypts journal content
  String decryptContent(String encrypted) {
    if (encrypted.isEmpty) return '';
    try {
      return AESEncryption.decryptText(encrypted, _passphrase);
    } catch (e) {
      return 'Error al descifrar contenido';
    }
  }

  /// Encrypts analysis/reflection using AES
  String encryptAnalysis(String analysis) {
    return AESEncryption.encryptText(analysis, _passphrase);
  }

  /// Decrypts analysis/reflection
  String decryptAnalysis(String encrypted) {
    if (encrypted.isEmpty) return '';
    try {
      return AESEncryption.decryptText(encrypted, _passphrase);
    } catch (e) {
      return 'Error al descifrar reflexión';
    }
  }

// =========================
  // HELPER METHODS
  // =========================

  /// Generates a new UUID for entry
  String generateEntryId() {
    return _uuid.v4();
  }

  /// Creates timestamp for entry
  String generateTimestamp() {
    return DateTime.now().toIso8601String();
  }

  // =========================
  // ANALYSIS METHODS (Gemini)
  // =========================

  /// Analyzes journal entry using Gemini AI
  /// Returns sentiment, archetype, and reflection
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
      // Return defaults on failure
      return {
        'sentiment': 'neutral',
        'sentimentScore': 0.5,
        'archetype': 'The Mirror',
        'reflection': 'Tu experiencia es válida y merece atención.',
      };
    }
  }

// =========================
  // COMBINED METHODS (Analysis + Save)
  // =========================

  /// Creates a new entry WITH Gemini analysis
  /// This is the main entry point used by alma_journal.dart
  Future<String> createEntryWithAnalysis({
    required String content,
  }) async {
    // Step 1: Analyze with Gemini AI
    final analysis = await analyzeEntry(content);
    
    final sentiment = analysis['sentiment'] as String;
    final sentimentScore = analysis['sentimentScore'] as double;
    final archetype = analysis['archetype'] as String;
    final reflection = analysis['reflection'] as String;

    // Step 2: Save encrypted entry
    return createEntry(
      content: content,
      sentiment: sentiment,
      sentimentScore: sentimentScore,
      archetype: archetype,
      reflection: reflection,
    );
  }

  // =========================
  // REPOSITORY PROXY METHODS
  // (Delegates to repository for data ops)
  // =========================

  /// Saves a journal entry (encrypts + calls repository)
  /// Note: For backwards compatibility - prefer createEntryWithAnalysis()
  Future<String> createEntry({
    required String content,
    required String sentiment,
    required double sentimentScore,
    required String archetype,
    required String reflection,
  }) async {
    final entryId = generateEntryId();
    final now = generateTimestamp();

    // Encrypt data
    final encryptedContent = encryptContent(content);
    final encryptedAnalysis = encryptAnalysis(reflection);

    final entry = {
      'id': entryId,
      'content_encrypted': encryptedContent,
      'analysis_encrypted': encryptedAnalysis,
      'sentiment': sentiment,
      'sentiment_score': sentimentScore,
      'archetype': archetype,
      'created_at': now,
      'updated_at': now,
    };

    await _repository.insertEntry(entry);
    return entryId;
  }

  /// Gets all journal entries (decrypts content on demand)
  Future<List<Map<String, dynamic>>> getEntries({bool decrypt = true}) async {
    final entries = await _repository.getEntries();

    if (!decrypt) return entries;

    // Decrypt content for each entry
    return entries.map((entry) {
      return {
        ...entry,
        'content_decrypted': decryptContent(entry['content_encrypted'] ?? ''),
        'analysis_decrypted': decryptAnalysis(entry['analysis_encrypted'] ?? ''),
      };
    }).toList();
  }

  /// Gets a single entry by ID
  Future<Map<String, dynamic>?> getEntryById(String entryId, {bool decrypt = true}) async {
    final entry = await _repository.getEntryById(entryId);

    if (entry == null) return null;
    if (!decrypt) return entry;

    return {
      ...entry,
      'content_decrypted': decryptContent(entry['content_encrypted'] ?? ''),
      'analysis_decrypted': decryptAnalysis(entry['analysis_encrypted'] ?? ''),
    };
  }

  /// Updates an existing entry
  Future<void> updateEntry({
    required String entryId,
    String? content,
    String? reflection,
    String? sentiment,
    double? sentimentScore,
    String? archetype,
  }) async {
    final entryMap = <String, dynamic>{};

    if (content != null) {
      entryMap['content_encrypted'] = encryptContent(content);
    }
    if (reflection != null) {
      entryMap['analysis_encrypted'] = encryptAnalysis(reflection);
    }
    if (sentiment != null) {
      entryMap['sentiment'] = sentiment;
    }
    if (sentimentScore != null) {
      entryMap['sentiment_score'] = sentimentScore;
    }
    if (archetype != null) {
      entryMap['archetype'] = archetype;
    }

    await _repository.updateEntry(entryId, entryMap);
  }

  /// Deletes an entry
  Future<void> deleteEntry(String entryId) async {
    await _repository.deleteEntry(entryId);
  }
}
