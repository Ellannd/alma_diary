class ReadingsState {
  final List<Map<String, dynamic>> readings;
  final Set<String> savedIds;
  final bool isLoading;
  final String? userId;
  final String? error;

  const ReadingsState({
    this.readings = const [],
    this.savedIds = const {},
    this.isLoading = false,
    this.userId,
    this.error,
  });

  ReadingsState copyWith({
    List<Map<String, dynamic>>? readings,
    Set<String>? savedIds,
    bool? isLoading,
    String? userId,
    String? error,
  }) {
    return ReadingsState(
      readings: readings ?? this.readings,
      savedIds: savedIds ?? this.savedIds,
      isLoading: isLoading ?? this.isLoading,
      userId: userId ?? this.userId,
      error: error,
    );
  }

  factory ReadingsState.initial() => const ReadingsState();
}