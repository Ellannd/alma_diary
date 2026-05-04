import 'package:alma_diary/features/ai/analysis/ai_services_impl.dart';
import 'package:alma_diary/features/ai/analysis/providers/gemini_provider.dart';
import 'package:alma_diary/features/ai/analysis/providers/huggingface_provider.dart';
import 'package:alma_diary/features/ai/analysis/providers/mock_provider.dart';
import 'package:alma_diary/features/ai/analysis/router/model_router.dart';
import 'package:flutter/material.dart';
import 'package:alma_diary/auth/alma_auth_session.dart';
import 'package:alma_diary/features/journal/data/journal_service.dart';
import 'package:alma_diary/core/logging/log_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


/// JournalEntry model for UI
class JournalEntryModel {
  final String id;
  final String content;
  final String reflection;
  final String sentiment;
  final double sentimentScore;
  final String archetype;
  final DateTime createdAt;
  final DateTime? updatedAt;

  JournalEntryModel({
    required this.id,
    required this.content,
    required this.reflection,
    required this.sentiment,
    required this.sentimentScore,
    required this.archetype,
    required this.createdAt,
    this.updatedAt,
  });

  factory JournalEntryModel.fromMap(Map<String, dynamic> map) {
    return JournalEntryModel(
      id: map['id'] ?? '',
      content: map['content_decrypted'] ?? map['content_encrypted'] ?? '',
      reflection: map['analysis_decrypted'] ?? map['analysis_encrypted'] ?? '',
      sentiment: map['sentiment'] ?? 'neutral',
      sentimentScore: (map['sentiment_score'] ?? 0.5).toDouble(),
      archetype: map['archetype'] ?? 'The Mirror',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.tryParse(map['updated_at']?.toString() ?? '') 
          : null,
    );
  }
}

/// JournalController - ORQUESTADOR LAYER
/// Handles:
/// - UI state management
/// - Transform raw data → UI models
/// - Calls JournalService (encrypt/decrypt)
/// - Calls JournalRepository via service
/// - Authentication handling
class JournalController extends ChangeNotifier {
  
  final JournalService _service = JournalService.instance;
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

  // State
  List<JournalEntryModel> _entries = [];
  JournalEntryModel? _currentEntry;
  bool _loading = false;
  bool _saving = false;
  bool _analyzing = false;
  String? _error;

  // Getters
  List<JournalEntryModel> get entries => _entries;
  JournalEntryModel? get currentEntry => _currentEntry;
  bool get loading => _loading;
  bool get saving => _saving;
  bool get analyzing => _analyzing;
  String? get error => _error;

  // =========================
  // CREATE ENTRY
  // =========================

  /// Creates a new journal entry with analysis
  Future<String?> createEntry({
    required String content,
    bool analyze = true,
  }) async {
    // Validate auth
    final auth = await AlmaAuthSession.ensureAuthenticated();
    if (!auth) {
      _setError('Autenticación fallida');
      return null;
    }

    // Validate content
    if (content.trim().isEmpty) {
      _setError('El texto no puede estar vacío');
      return null;
    }

    // Defaults
    String sentiment = 'neutral';
    double sentimentScore = 0.5;
    String archetype = 'The Mirror';
    String reflection = 'Tu experiencia es válida y merece atención.';

    // Analyze with AI
    if (analyze) {
      _setAnalyzing(true);
      try {
        final analysis = await aiService.analyze(content);
        sentiment = analysis.sentiment;
        sentimentScore = analysis.sentimentScore;
        archetype = analysis.archetype;
        reflection = analysis.reflection;
      } catch (e) {
        LogService.instance.error(
          'journal.analysis.error',
          context: {'entry': content.substring(0, 50)},
        );
      } finally {
        _setAnalyzing(false);
      }
    }

    // Save entry
    _setSaving(true);
    try {
      final entryId = await _service.createEntry(
        content: content,
        sentiment: sentiment,
        sentimentScore: sentimentScore,
        archetype: archetype,
        reflection: reflection,
      );

      LogService.instance.info(
        'journal.entry_created',
        context: {'entry_id': entryId},
      );

      _setSaving(false);
      _clearError();
      return entryId;
    } catch (e) {
      LogService.instance.error(
        'journal.create_failed',
        context: {'content': content.substring(0, 50)},
      );
      _setError('Error al guardar la entrada');
      _setSaving(false);
      return null;
    }
  }

  // =========================
  // GET ENTRIES
  // =========================

  /// Loads all journal entries
  Future<void> loadEntries() async {
    _setLoading(true);
    try {
      final entries = await _service.getEntries(decrypt: true);
      _entries = entries.map((e) => JournalEntryModel.fromMap(e)).toList();
      _clearError();
    } catch (e) {
      LogService.instance.error('journal.load_failed', context: {});
      _setError('Error al cargar las entradas');
    } finally {
      _setLoading(false);
    }
  }

  /// Loads a single entry by ID
  Future<JournalEntryModel?> loadEntryById(String entryId) async {
    _setLoading(true);
    try {
      final entry = await _service.getEntryById(entryId, decrypt: true);
      if (entry != null) {
        _currentEntry = JournalEntryModel.fromMap(entry);
        _clearError();
        return _currentEntry;
      }
      _setError('Entrada no encontrada');
      return null;
    } catch (e) {
      LogService.instance.error(
        'journal.load_by_id_failed',
        context: {'entry_id': entryId},
      );
      _setError('Error al cargar la entrada');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // =========================
  // UPDATE ENTRY
  // =========================

  /// Updates an existing entry
  Future<bool> updateEntry({
    required String entryId,
    String? content,
    String? reflection,
    String? sentiment,
    double? sentimentScore,
    String? archetype,
  }) async {
    _setSaving(true);
    try {
      await _service.updateEntry(
        entryId: entryId,
        content: content,
        reflection: reflection,
        sentiment: sentiment,
        sentimentScore: sentimentScore,
        archetype: archetype,
      );

      LogService.instance.info(
        'journal.entry_updated',
        context: {'entry_id': entryId},
      );

      _setSaving(false);
      _clearError();
      return true;
    } catch (e) {
      LogService.instance.error(
        'journal.update_failed',
        context: {'entry_id': entryId},
      );
      _setError('Error al actualizar la entrada');
      _setSaving(false);
      return false;
    }
  }

  // =========================
  // DELETE ENTRY
  // =========================

  /// Deletes an entry
  Future<bool> deleteEntry(String entryId) async {
    _setSaving(true);
    try {
      await _service.deleteEntry(entryId);

      LogService.instance.info(
        'journal.entry_deleted',
        context: {'entry_id': entryId},
      );

      // Remove from local list
      _entries.removeWhere((e) => e.id == entryId);

      _setSaving(false);
      _clearError();
      return true;
    } catch (e) {
      LogService.instance.error(
        'journal.delete_failed',
        context: {'entry_id': entryId},
      );
      _setError('Error al eliminar la entrada');
      _setSaving(false);
      return false;
    }
  }

  // =========================
  // HELPER METHODS
  // =========================

  /// Clears error state
  void clearError() {
    _clearError();
  }

  /// Clears current entry
  void clearCurrentEntry() {
    _currentEntry = null;
  }

  // =========================
  // PRIVATE METHODS
  // =========================

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setSaving(bool value) {
    _saving = value;
    notifyListeners();
  }

  void _setAnalyzing(bool value) {
    _analyzing = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

}
