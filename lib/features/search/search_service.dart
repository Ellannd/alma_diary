import 'package:alma_diary/core/crypto/crypto_provider.dart';
import 'package:alma_diary/models/search_result.dart';
import 'engine/search_engine.dart';
import 'search_repository.dart';

class SearchService {
  final SearchEngine engine = SearchEngine();
  late final SearchRepository repo;

  SearchService({required CryptoSession crypto}) {
    repo = SearchRepository(crypto: crypto);
  }

  Future<List<SearchResult>> search({
    required String userId,
    required String query,
  }) async {
    final results = <SearchResult>[];

    final journal     = await repo.getJournal(userId);
    final challenges  = await repo.getChallenges(userId);
    final quotes      = await repo.getQuotes();

    // ---------------- JOURNAL ----------------
    for (final j in journal) {
      final content  = (j['content_decrypted'] ?? '').toString();
      final analysis = (j['analysis_decrypted'] ?? '').toString();
      final title    = (j['title'] ?? '').toString();

      final score = engine.calculateScore(
        query: query,
        title: title,
        subtitle: content,
        tags: [analysis, j['sentiment'] ?? '', j['archetype'] ?? ''],
      );

      if (score > 0) {
        results.add(SearchResult(
          type: 'journal',
          score: score,
          entry: {
            ...j,
            // campos que consume SearchResult + dialogs
            'title': title,
            'subtitle': content,
            'content_decrypted': content,
            'analysis_decrypted': analysis,
          },
        ));
      }
    }

    // ---------------- CHALLENGES ----------------
    for (final c in challenges) {
      final challenge = (c['challenges'] ?? {}) as Map<String, dynamic>;
      final title     = (challenge['title'] ?? '').toString();
      final desc      = (challenge['description'] ?? '').toString();

      final score = engine.calculateScore(
        query: query,
        title: title,
        subtitle: desc,
        category: challenge['category'],
      );

      if (score > 0) {
        results.add(SearchResult(
          type: 'challenge',
          score: score,
          entry: {
            ...challenge,
            'type': 'challenge',
            'title': title,
            'subtitle': desc,
          },
        ));
      }
    }

    // ---------------- QUOTES ----------------
    for (final q in quotes) {
      final text   = (q['text'] ?? '').toString();
      final author = (q['author'] ?? '').toString();
      final tags   = List<String>.from(q['tags'] ?? []);

      // title: campo DB si existe, si no primeras 6 palabras del texto
      final title = (q['title'] as String?)?.isNotEmpty == true
          ? q['title'].toString()
          : text.split(' ').take(6).join(' ');

      final score = engine.calculateScore(
        query: query,
        title: title,
        subtitle: text,
        tags: [...tags, author],
      );

      if (score > 0) {
        results.add(SearchResult(
          type: 'quote',
          score: score,
          entry: {
            ...q,
            'type': 'quote',
            'title': title,
            'subtitle': text,
          },
        ));
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }
}