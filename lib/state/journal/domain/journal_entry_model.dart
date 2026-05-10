/// =========================
/// MODEL
/// =========================
class JournalEntryModel {
  final String id;
  final String content;
  final String reflection;
  final String sentiment;
  final double sentimentScore;
  final String archetype;
  final DateTime createdAt;
  final DateTime? updatedAt;

  JournalEntryModel({
    required this.id,
    required this.content,
    required this.reflection,
    required this.sentiment,
    required this.sentimentScore,
    required this.archetype,
    required this.createdAt,
    this.updatedAt,
  });

  factory JournalEntryModel.fromMap(Map<String, dynamic> map) {
    return JournalEntryModel(
      id: map['id'] ?? '',
      content: map['content_decrypted'] ?? map['content_encrypted'] ?? '',
      reflection: map['analysis_decrypted'] ?? map['analysis_encrypted'] ?? '',
      sentiment: map['sentiment'] ?? 'neutral',
      sentimentScore: (map['sentiment_score'] ?? 0.5).toDouble(),
      archetype: map['archetype'] ?? 'The Mirror',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at']?.toString() ?? '')
          : null,
    );
  }
}
