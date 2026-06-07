import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:alma_diary/core/constants.dart';
import 'package:alma_diary/core/logging/log_service.dart';

class SimilarEntry {
  final String id;
  final String title;
  final String contentV2;
  final DateTime createdAt;
  final String? sentiment;
  final String? archetype;
  final double similarity;

  const SimilarEntry({
    required this.id,
    required this.title,
    required this.contentV2,
    required this.createdAt,
    this.sentiment,
    this.archetype,
    required this.similarity,
  });

  factory SimilarEntry.fromJson(Map<String, dynamic> json) => SimilarEntry(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    contentV2: json['content_v2'] as String? ?? '',
    createdAt: DateTime.parse(json['created_at'] as String),
    sentiment: json['sentiment'] as String?,
    archetype: json['archetype'] as String?,
    similarity: (json['similarity'] as num).toDouble(),
  );

  String get formattedDate {
    final d = createdAt;
    return '${d.day}/${d.month}/${d.year}';
  }

  String get preview =>
      contentV2.length > 120 ? '${contentV2.substring(0, 120)}...' : contentV2;
}

class EmbeddingRepository {
  final String _baseUrl;
  final String _anonKey;

  EmbeddingRepository()
    : _baseUrl = EnvConfig.supabaseUrl,
      _anonKey = EnvConfig.supabaseAnonKey;

  // ── Generar y guardar embedding de una entrada ───────────────

  Future<bool> generateEmbedding({
    required String entryId,
    required String userId,
    String? plainText,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/functions/v1/generate-embedding'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_anonKey',
            },
            body: jsonEncode({
              'entry_id': entryId,
              'user_id': userId,
              'plain_text': ?plainText,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        LogService.instance.error(
          'embedding.generate.failed',
          error: 'HTTP ${response.statusCode}: ${response.body}',
        );
        return false;
      }

      return true;
    } catch (e, stack) {
      LogService.instance.error(
        'embedding.generate.error',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }

  // ── Buscar entradas similares ────────────────────────────────

  Future<List<SimilarEntry>> searchSimilar({
    required String userId,
    required String query,
    int matchCount = 5,
    double threshold = 0.75,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/functions/v1/search-similar-entries'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_anonKey',
            },
            body: jsonEncode({
              'user_id': userId,
              'query': query,
              'match_count': matchCount,
              'threshold': threshold,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        LogService.instance.error(
          'embedding.search.failed',
          error: 'HTTP ${response.statusCode}: ${response.body}',
        );
        return [];
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final entries = data['entries'] as List<dynamic>? ?? [];

      return entries
          .map((e) => SimilarEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      LogService.instance.error(
        'embedding.search.error',
        error: e,
        stackTrace: stack,
      );
      return [];
    }
  }
}
