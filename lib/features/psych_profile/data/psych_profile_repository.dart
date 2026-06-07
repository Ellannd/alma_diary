import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alma_diary/features/psych_profile/domain/psych_profile.dart';
import 'package:alma_diary/core/constants.dart';
import 'package:alma_diary/core/logging/log_service.dart';

class PsychProfileRepository {
  final SupabaseClient _client;

  PsychProfileRepository(this._client);

  // ── Leer perfil actual ───────────────────────────────────────

  Future<PsychProfile?> getProfile(String userId) async {
    final data = await _client
        .from('psychological_profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) return null;
    return PsychProfile.fromJson(data);
  }

  // ── Historial de versiones ───────────────────────────────────

  Future<List<PsychProfile>> getProfileHistory(String userId) async {
    final data = await _client
        .from('psychological_profile_history')
        .select('profile_snapshot, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(10);

    return (data as List).map((e) {
      final map = e as Map<String, dynamic>;
      final snapshot = map['profile_snapshot'] as Map<String, dynamic>;
      return PsychProfile.fromJson(snapshot);
    }).toList();
  }

  // ── Cuántas entradas desde el último update ──────────────────

  Future<int> entriesSinceLastUpdate(String userId) async {
    final data = await _client.rpc(
      'entries_since_last_profile_update',
      params: {'p_user_id': userId},
    );
    return (data as int?) ?? 0;
  }

  // ── Generar perfil via Edge Function ─────────────────────────

  Future<PsychProfile?> generateProfile(String userId) async {
    try {
      final uri = Uri.parse(
        '${EnvConfig.supabaseUrl}/functions/v1/generate-psych-profile',
      );

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${EnvConfig.supabaseAnonKey}',
            },
            body: jsonEncode({'user_id': userId}),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) {
        LogService.instance.error(
          'psych_profile.generate.failed',
          error: 'HTTP ${response.statusCode}: ${response.body}',
        );
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final profile = data['profile'] as Map<String, dynamic>?;
      if (profile == null) return null;

      // Releer el perfil guardado en Supabase para tener el id y timestamps
      return await getProfile(userId);
    } catch (e, stack) {
      LogService.instance.error(
        'psych_profile.generate.error',
        error: e,
        stackTrace: stack,
      );
      return null;
    }
  }
}
