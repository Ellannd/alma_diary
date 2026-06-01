import 'package:alma_diary/core/analytics/alma_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alma_diary/features/journal/data/journal_service.dart';
import 'package:alma_diary/core/logging/log_service.dart';

import "package:alma_diary/state/journal/journal_state.dart";

import "domain/journal_entry_model.dart";



/// =========================
/// CONTROLLER (MODERNO RIVERPOD)
/// =========================
class JournalController extends Notifier<JournalState> {
  late final JournalService service;

  @override
  JournalState build() {
    service = ref.read(journalServiceProvider);

    return const JournalState();
  }

  /// =========================
  /// CREATE ENTRY
  /// =========================
  Future<({String archetype, String entryId, String sentiment})?> createEntry({
    required String content,
    bool analyze = true,
  }) async {
    if (content.trim().isEmpty) {
      state = state.copyWith(error: 'El texto no puede estar vacío');
      return null;
    }

    state = state.copyWith(analyzing: analyze, saving: !analyze);

    try {
      final entryId = await service.createEntryWithAnalysis(
        content: content,
        title: JournalEntryModel.defaultTitle(DateTime.now()),
      );

      await AlmaAnalytics.journalEntryCreated(
        archetype: entryId.archetype,
        sentiment: entryId.sentiment,
      );

      state = state.copyWith(saving: false, analyzing: false, error: null);
      await loadEntries();
      return entryId;
      
    } catch (e, st) {
      LogService.instance.error('journal.create_failed', error: e, stackTrace: st);
      state = state.copyWith(
        saving: false,
        analyzing: false,
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
    } catch (e, st) {
      LogService.instance.error('journal.load_failed',
      error: e,
      stackTrace: st
      );
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
    } catch (e, st) {
      LogService.instance.error('journal.load_by_id_failed',
      error: e,
      stackTrace: st
      );
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
    } catch (e, st) {
      LogService.instance.error('journal.update_failed',
      error: e,
      stackTrace: st
      );
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
    } catch (e, st) {
      LogService.instance.error('journal.delete_failed',
      error: e,
      stackTrace: st
      );
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

final journalControllerProvider =
    NotifierProvider<JournalController, JournalState>(
  JournalController.new,
);


 