import 'package:supabase_flutter/supabase_flutter.dart';
import "package:alma_diary/core/logging/log_service.dart";
class ReadingService {
  static final ReadingService instance = ReadingService._internal();

  ReadingService._internal();

  final _client = Supabase.instance.client;


  Future<List<Map<String, dynamic>>> fetchAllReadings() async {
    final response = await _client
        .from('readings')
        .select();

    return List<Map<String, dynamic>>.from(response);
  }
  /// Obtener lecturas recomendadas basadas en tags
Future<List<Map<String, dynamic>>> getRecommendedReadings({
  required List<String> userTags,
  int limit = 10,
}) async {
  try {
    // 🧠 Limpieza defensiva de tags del usuario
    final safeTags = userTags
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .toList();

    // 🟡 Fallback si no hay tags útiles
    if (safeTags.isEmpty) {
      return await getExploreReadings(limit: limit);
    }

    final response = await _client
        .from('readings')
        .select()
        .overlaps('tags', safeTags)
        .order('created_at', ascending: false)
        .limit(limit);

    final data = List<Map<String, dynamic>>.from(response);

    // 🔴 Fallback inteligente si no hay matches
    if (data.isEmpty) {
      return await getExploreReadings(limit: limit);
    }

    return data;
  } catch (e) {
    LogService.instance.error(
      'reading.recommended_failed',
      error: e,
    );

    // 🔥 nunca romper UI
    return await getExploreReadings(limit: limit);
  }
}

  /// 🌿 Lecturas generales (explorar)
  Future<List<Map<String, dynamic>>> getExploreReadings({
    int limit = 10,
  }) async {
    try {
      final response = await _client
          .from('readings')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      LogService.instance.error(
        'reading.explore_failed',
        error: e,
      );
      return [];
    }
  }

  /// 🧠 Lecturas por categoría
  Future<List<Map<String, dynamic>>> getReadingsByCategory(
    String category,
  ) async {
    try {
      final response = await _client
          .from('readings')
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      LogService.instance.error(
        'reading.category_failed',
        error: e,
        context: {
          'category': category,
        },
      );
      return [];
    }
  }

  /// 🔎 Buscar lecturas (simple)
  Future<List<Map<String, dynamic>>> searchReadings(String query) async {
    try {
      final response = await _client
          .from('readings')
          .select()
          .ilike('title', '%$query%');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      LogService.instance.error(
        'reading.search_failed',
        error: e,
        context: {
          'query': query,
        },
      );
      return [];
    }
  }
}