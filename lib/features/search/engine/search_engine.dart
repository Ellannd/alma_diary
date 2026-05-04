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
}