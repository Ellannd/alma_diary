class SearchEngine {
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