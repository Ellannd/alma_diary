import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alma_diary/features/journal/data/journal_service.dart';
import 'package:alma_diary/core/logging/log_service.dart';

import "package:alma_diary/state/reflections/reflection_state.dart";

/// =========================
/// PROVIDERS
/// =========================
final journalServiceProvider = Provider<JournalService>((ref) {
  return JournalService.instance;
});

final reflectionControllerProvider =
    NotifierProvider<ReflectionController, ReflectionState>(
  ReflectionController.new,
);

/// =========================
/// CONTROLLER (NotifierProvider)
/// =========================
class ReflectionController extends Notifier<ReflectionState> {
  late final JournalService _service;

  @override
  ReflectionState build() {
    _service = ref.read(journalServiceProvider);
    return const ReflectionState();
  }

  /// =========================
  /// LOAD ALL ENTRIES
  /// =========================
  Future<void> loadEntries() async {
    state = state.copyWith(loading: true, error: null);

    try {
      final entries = await _service.getEntries(decrypt: true);

      state = state.copyWith(
        entries: entries,
        loading: false,
      );
    } catch (e, st) {
      LogService.instance.error(
        'reflection.load_entries_failed',
        error: e,
        stackTrace: st,
      );

      state = state.copyWith(
        loading: false,
        error: 'Error al cargar las entradas',
      );
    }
  }

  /// =========================
  /// LOAD SINGLE ENTRY
  /// =========================
  Future<void> loadEntry(String entryId) async {
    state = state.copyWith(loading: true, error: null);

    try {
      final entry =
          await _service.getEntryById(entryId, decrypt: true);

      state = state.copyWith(
        selectedEntry: entry,
        loading: false,
      );
    } catch (e, st) {
      LogService.instance.error(
        'reflection.load_entry_failed',
        error: e,
        stackTrace: st,
        context: {'entry_id': entryId},
      );

      state = state.copyWith(
        loading: false,
        error: 'Error al cargar la entrada',
      );
    }
  }

  /// =========================
/// DELETE ENTRY
/// =========================
Future<void> deleteEntry(String entryId) async {
  try {
    await _service.deleteEntry(entryId);

    // Elimina del estado local sin recargar toda la lista
    state = state.copyWith(
      entries: state.entries
          .where((e) => e['id'] != entryId)
          .toList(),
    );

    LogService.instance.info(
      'reflection.delete_success',
      context: {'entry_id': entryId},
    );
  } catch (e, st) {
    LogService.instance.error(
      'reflection.delete_failed',
      error: e,
      stackTrace: st,
      context: {'entry_id': entryId},
    );
    state = state.copyWith(error: 'No se pudo borrar la entrada');
  }
}

/// =========================
/// UPDATE TITLE
/// =========================
Future<void> updateTitle({
  required String entryId,
  required String title,
}) async {
  try {
    await _service.updateEntry(entryId: entryId, title: title);

    // Actualiza solo esa entrada en el estado local
    state = state.copyWith(
      entries: state.entries.map((e) {
        if (e['id'] == entryId) return {...e, 'title': title};
        return e;
      }).toList(),
    );

    LogService.instance.info(
      'reflection.update_title_success',
      context: {'entry_id': entryId},
    );
  } catch (e, st) {
    LogService.instance.error(
      'reflection.update_title_failed',
      error: e,
      stackTrace: st,
      context: {'entry_id': entryId},
    );
    state = state.copyWith(error: 'No se pudo actualizar el título');
  }
}

  /// =========================
  /// CLEAR SELECTION
  /// =========================
  void clearSelection() {
    state = state.copyWith(selectedEntry: null);
  }

  /// =========================
  /// REFRESH
  /// =========================
  Future<void> refresh() async {
    await loadEntries();
  }
}