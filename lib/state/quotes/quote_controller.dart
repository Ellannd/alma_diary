import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alma_diary/features/quotes/engine/quotes_engine.dart';

class QuotesState {
  final bool loading;
  final List<AlmaQuote> quotes;
  final int pinnedIndex;

  const QuotesState({
    this.loading = false,
    this.quotes = const [],
    this.pinnedIndex = 0,
  });

  QuotesState copyWith({
    bool? loading,
    List<AlmaQuote>? quotes,
    int? pinnedIndex,
  }) {
    return QuotesState(
      loading: loading ?? this.loading,
      quotes: quotes ?? this.quotes,
      pinnedIndex: pinnedIndex ?? this.pinnedIndex,
    );
  }
}

final quotesControllerProvider =
    NotifierProvider<QuotesController, QuotesState>(
  QuotesController.new,
);

class QuotesController extends Notifier<QuotesState> {
  late QuotesEngine _engine;

  @override
  QuotesState build() {
    // estado inicial
    return const QuotesState();
  }

  // =========================
  // INIT ENGINE
  // =========================
  void init({
    required String arquetipo,
    required List<String> nodosDolor,
  }) {
    _engine = QuotesEngine(
      arquetipo: arquetipo,
      nodosDolor: nodosDolor,
    );
  }

  // =========================
  // LOAD QUOTES
  // =========================
  Future<void> loadQuotes() async {
    state = state.copyWith(loading: true);

    try {
      final data = await _engine.getDailyQuotes();

      state = state.copyWith(
        quotes: data,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        quotes: [],
      );
    }
  }

  // =========================
  // PIN QUOTE
  // =========================
  void pinQuote(int index) {
    state = state.copyWith(pinnedIndex: index);
  }

  AlmaQuote? get pinnedQuote {
    if (state.quotes.isEmpty) return null;
    if (state.pinnedIndex >= state.quotes.length) return null;
    return state.quotes[state.pinnedIndex];
  }
}