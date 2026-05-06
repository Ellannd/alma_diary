import 'package:alma_diary/models/search_result.dart';

class SearchEngine {
  /// Normaliza texto
  String normalize(String text) {
    return text.toLowerCase().trim();
  }

  /// Calcula score de relevancia
  int scoreEntry({
    required Map<String, dynamic> entry,
    required String query,
    String? archetypeFilter,
  }) {
    int score = 0;

    final q = normalize(query);
    final sentiment = normalize(entry['sentiment'] ?? '');
    final archetype = normalize(entry['archetype'] ?? '');
    final content = normalize(entry['content_encrypted'] ?? '');

    // 1. match directo
    if (sentiment.contains(q)) score += 3;
    if (archetype.contains(q)) score += 3;
    if (content.contains(q)) score += 1;

    // 2. filtro arquetipo activo
    if (archetypeFilter != null && archetype == archetypeFilter.toLowerCase()) {
      score += 5;
    }

    // 3. boost por coincidencia fuerte
    if (content.startsWith(q)) score += 2;

    return score;
  }

  /// Ordena resultados por relevancia
  List<SearchResult> rankResults({
  required List<Map<String, dynamic>> results,
  required String query,
  String? archetypeFilter,
}) {
  final scored = results.map((e) {
    final score = scoreEntry(
      entry: e,
      query: query,
      archetypeFilter: archetypeFilter,
    );

    return SearchResult(
      entry: e,
      score: score,
      type: e['type'] ?? 'journal',
    );
  }).toList();

  scored.sort((a, b) => b.score.compareTo(a.score));

  return scored.where((e) => e.score > 0).toList();
}
  int _scoreMatch(String text, String query) {
    final t = text.toLowerCase();
    final q = query.toLowerCase();

    if (t == q) return 10;
    if (t.contains(q)) return 6;

    final words = q.split(' ');
    int score = 0;

    for (final w in words) {
      if (w.isEmpty) continue;
      if (t.contains(w)) score += 2;
    }

    return score;
  }

  int calculateScore({
    required String query,
    required String title,
    required String subtitle,
    List<String>? tags,
    String? category,
  }) {
    int score = 0;

    score += _scoreMatch(title, query) * 3;
    score += _scoreMatch(subtitle, query) * 2;

    if (category != null) {
      score += _scoreMatch(category, query) * 2;
    }

    if (tags != null) {
      for (final tag in tags) {
        score += _scoreMatch(tag, query);
      }
    }

    return score;
  }
}