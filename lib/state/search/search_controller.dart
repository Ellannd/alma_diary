import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:alma_diary/features/search/search_service.dart";
import "package:alma_diary/state/search/search_state.dart";

class SearchController extends Notifier<SearchState> {
  late final SearchService _service;

  @override
  SearchState build() {
    _service = SearchService();
    return const SearchState();
  }

  Future<void> search({
    required String userId,
    required String query,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await _service.search(
        userId: userId,
        query: query,
      );

      state = state.copyWith(
        results: results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clear() {
    state = const SearchState();
  }
}