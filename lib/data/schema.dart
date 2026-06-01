import 'package:uuid/uuid.dart';

class JournalEntry {
  final String id;
  final String? userId;
  final String title;
  final String contentV2;       // content_v2 — cifrado
  final String? analysisV2;     // analysis_v2 — cifrado
  final String? sentiment;
  final double? sentimentScore;
  final String? archetype;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Campos descifrados — no van a DB, se populan en runtime
  final String? contentDecrypted;
  final String? analysisDecrypted;

  JournalEntry({
    String? id,
    this.userId,
    this.title = '',
    required this.contentV2,
    this.analysisV2,
    this.sentiment,
    this.sentimentScore,
    this.archetype,
    DateTime? createdAt,
    this.updatedAt,
    this.contentDecrypted,
    this.analysisDecrypted,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Para insertar/actualizar en Supabase
  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'content_v2': contentV2,
        'analysis_v2': analysisV2,
        'sentiment': sentiment,
        'sentiment_score': sentimentScore,
        'archetype': archetype,
        // created_at y updated_at los maneja Supabase
      };

  /// Para leer desde Supabase
  static JournalEntry fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'],
        userId: json['user_id'],
        title: (json['title'] ?? '').toString(),
        contentV2: (json['content_v2'] ?? '').toString(),
        analysisV2: json['analysis_v2']?.toString(),
        sentiment: json['sentiment']?.toString(),
        sentimentScore: json['sentiment_score'] != null
            ? (json['sentiment_score'] as num).toDouble()
            : null,
        archetype: json['archetype']?.toString(),
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'].toString()).toLocal()
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'].toString()).toLocal()
            : null,
      );

  /// Copia con campos descifrados populados — útil después del decrypt
  JournalEntry withDecrypted({
    String? contentDecrypted,
    String? analysisDecrypted,
  }) =>
      JournalEntry(
        id: id,
        userId: userId,
        title: title,
        contentV2: contentV2,
        analysisV2: analysisV2,
        sentiment: sentiment,
        sentimentScore: sentimentScore,
        archetype: archetype,
        createdAt: createdAt,
        updatedAt: updatedAt,
        contentDecrypted: contentDecrypted ?? this.contentDecrypted,
        analysisDecrypted: analysisDecrypted ?? this.analysisDecrypted,
      );
}