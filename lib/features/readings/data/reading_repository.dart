import 'package:supabase_flutter/supabase_flutter.dart';

/// ReadingRepository - Data Access Layer
/// Responsibilities:
/// - Pure Supabase queries only
/// - No business logic
/// - No state management
class ReadingRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Obtener todas las lecturas
  Future<List<Map<String, dynamic>>> getReadings() async {
    final res = await _client
        .from('readings')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  /// Guardar lectura del usuario
  Future<void> saveReading({
    required String userId,
    required String readingId,
  }) async {
    await _client.from('saved_readings').insert({
      'user_id': userId,
      'reading_id': readingId,
    });
  }

  /// Obtener IDs guardados
  Future<Set<String>> getSavedReadingIds(String userId) async {
    final res = await _client
        .from('saved_readings')
        .select('reading_id')
        .eq('user_id', userId);

    return res.map<String>((e) => e['reading_id'] as String).toSet();
  }

  /// Eliminar guardado
  Future<void> removeSavedReading({
    required String userId,
    required String readingId,
  }) async {
    await _client
        .from('saved_readings')
        .delete()
        .eq('user_id', userId)
        .eq('reading_id', readingId);
  }
}
