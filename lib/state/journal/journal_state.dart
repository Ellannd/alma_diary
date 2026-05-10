import "domain/journal_entry_model.dart";

/// =========================
/// STATE
/// =========================
class JournalState {
  final List<JournalEntryModel> entries;
  final JournalEntryModel? currentEntry;
  final bool loading;
  final bool saving;
  final bool analyzing;
  final String? error;

  const JournalState({
    this.entries = const [],
    this.currentEntry,
    this.loading = false,
    this.saving = false,
    this.analyzing = false,
    this.error,
  });

  JournalState copyWith({
    List<JournalEntryModel>? entries,
    JournalEntryModel? currentEntry,
    bool? loading,
    bool? saving,
    bool? analyzing,
    String? error,
  }) {
    return JournalState(
      entries: entries ?? this.entries,
      currentEntry: currentEntry ?? this.currentEntry,
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      analyzing: analyzing ?? this.analyzing,
      error: error,
    );
  }
}