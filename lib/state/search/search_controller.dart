import 'package:alma_diary/core/logging/log_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alma_diary/core/crypto/crypto_provider.dart';
import 'package:alma_diary/features/search/search_service.dart';
import 'package:alma_diary/state/search/search_state.dart';

final searchControllerProvider =
    AsyncNotifierProvider<SearchController, SearchState>(
  SearchController.new,
);

class SearchController extends AsyncNotifier<SearchState> {
  late final SearchService _service;

  @override
  Future<SearchState> build() async {
    // Espera a que la sesión cripto esté lista antes de cualquier búsqueda
    final crypto = await ref.watch(cryptoSessionProvider.future);
    _service = SearchService(crypto: crypto);
    return const SearchState();
  }

  Future<void> search({
    required String userId,
    required String query,
  }) async {
    final current = state.asData?.value ?? const SearchState();
    state = AsyncData(current.copyWith(isLoading: true, error: null));

    try {
      final results = await _service.search(userId: userId, query: query);
      state = AsyncData(current.copyWith(results: results, isLoading: false));
    } catch (e, st) {
      LogService.instance.error('search.failed', error: e, stackTrace: st);
      state = AsyncData(current.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void clear() {
    state = const AsyncData(SearchState());
  }
}