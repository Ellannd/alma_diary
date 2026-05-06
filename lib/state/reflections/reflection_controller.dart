import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alma_diary/features/journal/data/journal_service.dart';
import 'package:alma_diary/core/logging/log_service.dart';

import "package:alma_diary/state/reflections/reflection_state.dart";
import "package:alma_diary/state/reflections/reflection_provider.dart";



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