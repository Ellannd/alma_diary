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