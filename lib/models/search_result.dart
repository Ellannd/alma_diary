class SearchResult {
  final Map<String, dynamic> entry;
  final int score;
  final String type;

  SearchResult({
    required this.entry,
    required this.score,
    required this.type,
  });

  String get title => entry['title'] ?? 'Sin título';

  String get subtitle =>
      entry['subtitle'] ??
      entry['content'] ??
      entry['sentiment'] ??
      '';
}