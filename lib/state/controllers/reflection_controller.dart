import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alma_diary/features/journal/data/journal_service.dart';
import 'package:alma_diary/core/logging/log_service.dart';

/// =========================
/// STATE
/// =========================
class ReflectionState {
  final List<Map<String, dynamic>> entries;
  final Map<String, dynamic>? selectedEntry;
  final bool loading;
  final String? error;

  const ReflectionState({
    this.entries = const [],
    this.selectedEntry,
    this.loading = false,
    this.error,
  });

  ReflectionState copyWith({
    List<Map<String, dynamic>>? entries,
    Map<String, dynamic>? selectedEntry,
    bool? loading,
    String? error,
  }) {
    return ReflectionState(
      entries: entries ?? this.entries,
      selectedEntry: selectedEntry ?? this.selectedEntry,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

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