import "package:alma_diary/features/quotes/engine/quotes_engine.dart";

class QuotesState {
  final List<AlmaQuote> quotes;
  final bool loading;
  final int pinnedIndex;

  const QuotesState({
    this.quotes = const [],
    this.loading = false,
    this.pinnedIndex = 0,
  });

  QuotesState copyWith({
    List<AlmaQuote>? quotes,
    bool? loading,
    int? pinnedIndex,
  }) {
    return QuotesState(
      quotes: quotes ?? this.quotes,
      loading: loading ?? this.loading,
      pinnedIndex: pinnedIndex ?? this.pinnedIndex,
    );
  }
}