// lib/features/embeddings/state/similar_entries_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alma_diary/features/embeddings/data/embeddings_repository.dart';
import 'package:alma_diary/state/profile/profile_controller.dart';
import 'package:alma_diary/core/logging/log_service.dart';

// ── Estado ───────────────────────────────────────────────────────

class SimilarEntriesState {
  final List<SimilarEntry> entries;
  final bool isLoading;
  final String? lastQuery;

  const SimilarEntriesState({
    this.entries = const [],
    this.isLoading = false,
    this.lastQuery,
  });

  SimilarEntriesState copyWith({
    List<SimilarEntry>? entries,
    bool? isLoading,
    String? lastQuery,
  }) => SimilarEntriesState(
    entries: entries ?? this.entries,
    isLoading: isLoading ?? this.isLoading,
    lastQuery: lastQuery ?? this.lastQuery,
  );

  bool get hasResults => entries.isNotEmpty;
}

// ── Notifier ─────────────────────────────────────────────────────

class SimilarEntriesNotifier extends Notifier<SimilarEntriesState> {
  late EmbeddingRepository _repo;

  @override
  SimilarEntriesState build() {
    _repo = EmbeddingRepository();
    return const SimilarEntriesState();
  }

  Future<void> search(String query) async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null || query.trim().isEmpty) return;

    // No relanzar si es la misma query
    if (query == state.lastQuery && state.hasResults) return;

    state = state.copyWith(isLoading: true, lastQuery: query);

    final entries = await _repo.searchSimilar(userId: userId, query: query);

    LogService.instance.info(
      'similar_entries.search',
      context: {'query': query, 'results': entries.length},
    );

    state = state.copyWith(entries: entries, isLoading: false);
  }

  Future<void> searchFromChat(String chatMessage) async {
    // Solo busca si el mensaje tiene suficiente contenido
    if (chatMessage.trim().length < 20) return;
    await search(chatMessage);
  }

  void clear() => state = const SimilarEntriesState();
}

// ── Provider ─────────────────────────────────────────────────────

final similarEntriesProvider =
    NotifierProvider<SimilarEntriesNotifier, SimilarEntriesState>(
      SimilarEntriesNotifier.new,
    );
