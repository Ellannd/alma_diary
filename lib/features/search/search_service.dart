import '../../models/search_result.dart';
import 'search_engine.dart';
import 'search_repository.dart';

class SearchService {
  final SearchRepository repo = SearchRepository();
  final SearchEngine engine = SearchEngine();

  Future<List<SearchResult>> search({
    required String userId,
    required String query,
  }) async {
    final results = <SearchResult>[];

    final journal = await repo.getJournal(userId);
    final reflections = await repo.getReflections(userId);
    final challenges = await repo.getChallenges(userId);
    final quotes = await repo.getQuotes();

    // ---------------- JOURNAL ----------------
    for (final j in journal) {
      final rawContent = (j['content_encrypted'] ?? '').toString();

      final score = engine.calculateScore(
        query: query,
        title: '', // no tienes title real
        subtitle: rawContent,
      );

      if (score > 0) {
        results.add(
          SearchResult(
            type: 'journal',
            entry: j,
            score: score,
          ),
        );
  }
}

    // ---------------- REFLECTIONS ----------------
    for (final r in reflections) {
      final score = engine.calculateScore(
        query: query,
        title: r['title'] ?? '',
        subtitle: r['content'] ?? '',
      );

      if (score > 0) {
        results.add(
          SearchResult(
            entry: {
              ...r,
              'type': 'reflection',
            },
            type: 'reflection',
            score: score,
          ),
        );
      }
    }

    // ---------------- CHALLENGES ----------------
    for (final c in challenges) {
      final challenge = c['challenges'] ?? {};

      final score = engine.calculateScore(
        query: query,
        title: challenge['title'] ?? '',
        subtitle: challenge['description'] ?? '',
        category: challenge['category'],
      );

      if (score > 0) {
        results.add(
          SearchResult(
            entry: {
              ...challenge,
              'type': 'challenge',
            },
            type: 'challenge',
            score: score,
          ),
        );
      }
    }

    // ---------------- QUOTES ----------------
    for (final q in quotes) {
      final score = engine.calculateScore(
        query: query,
        title: q['text'] ?? '',
        subtitle: '',
      );

      if (score > 0) {
        results.add(
          SearchResult(
            entry: {
              ...q,
              'type': 'quote',
            },
            type: 'quote',
            score: score,
          ),
        );
      }
    }

    // SORT SAFE (evita null issues)
    results.sort((a, b) => b.score.compareTo(a.score));

    return results;
  }


}