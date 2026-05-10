import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alma_diary/auth/alma_auth_session.dart';
import 'package:alma_diary/features/journal/data/journal_service.dart';
import 'package:alma_diary/core/logging/log_service.dart';

import 'package:alma_diary/ai/analysis/ai_services_impl.dart';
import "package:alma_diary/state/journal/journal_state.dart";

import 'package:alma_diary/ai/analysis/providers/gemini_provider.dart';
import 'package:alma_diary/ai/analysis/providers/huggingface_provider.dart';
import 'package:alma_diary/ai/analysis/providers/mock_provider.dart';
import 'package:alma_diary/ai/analysis/router/model_router.dart';
import "domain/journal_entry_model.dart";

import 'package:flutter_dotenv/flutter_dotenv.dart';


/// =========================
/// CONTROLLER (MODERNO RIVERPOD)
/// =========================
class JournalController extends Notifier<JournalState> {
  late final JournalService service;
  late final AIServiceImpl ai;

  @override
  JournalState build() {
    service = ref.read(journalServiceProvider);
    ai = ref.read(aiServiceProvider);

    return const JournalState();
  }

  /// =========================
  /// CREATE ENTRY
  /// =========================
  Future<String?> createEntry({
    required String content,
    bool analyze = true,
  }) async {
    final auth = await AlmaAuthSession.ensureAuthenticated();
    if (!auth) {
      state = state.copyWith(error: 'Autenticación fallida');
      return null;
    }

    if (content.trim().isEmpty) {
      state = state.copyWith(error: 'El texto no puede estar vacío');
      return null;
    }

    String sentiment = 'neutral';
    double sentimentScore = 0.5;
    String archetype = 'The Mirror';
    String reflection = 'Tu experiencia es válida y merece atención.';

    if (analyze) {
      state = state.copyWith(analyzing: true);
      try {
        final analysis = await ai.analyze(content);
        sentiment = analysis.sentiment;
        sentimentScore = analysis.sentimentScore;
        archetype = analysis.archetype;
        reflection = analysis.reflection;
      } catch (e) {
        LogService.instance.error('journal.analysis.error');
      } finally {
        state = state.copyWith(analyzing: false);
      }
    }

    state = state.copyWith(saving: true);

    try {
      final entryId = await service.createEntry(
        content: content,
        sentiment: sentiment,
        sentimentScore: sentimentScore,
        archetype: archetype,
        reflection: reflection,
      );

      state = state.copyWith(saving: false, error: null);
      await loadEntries();

      return entryId;
    } catch (e) {
      LogService.instance.error('journal.create_failed');
      state = state.copyWith(
        saving: false,
        error: 'Error al guardar la entrada',
      );
      return null;
    }
  }

  /// =========================
  /// LOAD ENTRIES
  /// =========================
  Future<void> loadEntries() async {
    state = state.copyWith(loading: true);

    try {
      final entries = await service.getEntries(decrypt: true);

      final mapped = entries
          .map((e) => JournalEntryModel.fromMap(e))
          .toList();

      state = state.copyWith(
        entries: mapped,
        loading: false,
        error: null,
      );
    } catch (e) {
      LogService.instance.error('journal.load_failed');
      state = state.copyWith(
        loading: false,
        error: 'Error al cargar las entradas',
      );
    }
  }

  /// =========================
  /// LOAD BY ID
  /// =========================
  Future<JournalEntryModel?> loadEntryById(String id) async {
    state = state.copyWith(loading: true);

    try {
      final entry = await service.getEntryById(id, decrypt: true);

      if (entry == null) {
        state = state.copyWith(
          loading: false,
          error: 'Entrada no encontrada',
        );
        return null;
      }

      final model = JournalEntryModel.fromMap(entry);

      state = state.copyWith(
        currentEntry: model,
        loading: false,
        error: null,
      );

      return model;
    } catch (e) {
      LogService.instance.error('journal.load_by_id_failed');
      state = state.copyWith(
        loading: false,
        error: 'Error al cargar la entrada',
      );
      return null;
    }
  }

  /// =========================
  /// UPDATE
  /// =========================
  Future<bool> updateEntry({
    required String entryId,
    String? content,
    String? reflection,
    String? sentiment,
    double? sentimentScore,
    String? archetype,
  }) async {
    state = state.copyWith(saving: true);

    try {
      await service.updateEntry(
        entryId: entryId,
        content: content,
        reflection: reflection,
        sentiment: sentiment,
        sentimentScore: sentimentScore,
        archetype: archetype,
      );

      state = state.copyWith(saving: false, error: null);
      await loadEntries();
      return true;
    } catch (e) {
      LogService.instance.error('journal.update_failed');
      state = state.copyWith(
        saving: false,
        error: 'Error al actualizar la entrada',
      );
      return false;
    }
  }

  /// =========================
  /// DELETE
  /// =========================
  Future<bool> deleteEntry(String entryId) async {
    state = state.copyWith(saving: true);

    try {
      await service.deleteEntry(entryId);

      final updated =
          state.entries.where((e) => e.id != entryId).toList();

      state = state.copyWith(
        entries: updated,
        saving: false,
        error: null,
      );

      return true;
    } catch (e) {
      LogService.instance.error('journal.delete_failed');
      state = state.copyWith(
        saving: false,
        error: 'Error al eliminar la entrada',
      );
      return false;
    }
  }

  /// =========================
  /// HELPERS
  /// =========================
  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearCurrentEntry() {
    state = state.copyWith(currentEntry: null);
  }
}


/// =========================
/// PROVIDERS
/// =========================
final journalServiceProvider = Provider<JournalService>((ref) {
  return JournalService.instance;
});

final aiServiceProvider = Provider<AIServiceImpl>((ref) {
  return AIServiceImpl(
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
});

final journalControllerProvider =
    NotifierProvider<JournalController, JournalState>(
  JournalController.new,
);


 