import "package:alma_diary/ai/analysis/domain/analysis_result.dart";

class AnalysisState {
  final AnalysisResult? result;
  final bool loading;
  final String? error;

  const AnalysisState({
    this.result,
    this.loading = false,
    this.error,
  });

  AnalysisState copyWith({
    AnalysisResult? result,
    bool? loading,
    String? error,
  }) {
    return AnalysisState(
      result: result ?? this.result,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  factory AnalysisState.initial() => const AnalysisState();
}