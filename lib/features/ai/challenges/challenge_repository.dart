import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../ai/engines/challenges_engine_v2.dart';

/// ChallengeRepository - Data Access Layer
///Responsibilities:
/// - Pure Supabase queries only
/// - No business logic
/// - No state management
class ChallengeRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Get all active challenges from catalogue
  Future<List<Challenge>> getChallenges() async {
    final res = await _client
        .from('challenges')
        .select()
        .eq('active', true);

    return List<Map<String, dynamic>>.from(res)
        .map((e) => Challenge.fromMap(e))
        .toList();
  }

  /// Get user's started challenges
  Future<List<UserChallenge>> getUserChallenges(String userId) async {
    final res = await _client
        .from('user_challenges')
        .select()
        .eq('user_id', userId);

    return List<Map<String, dynamic>>.from(res)
        .map((e) => UserChallenge.fromMap(e))
        .toList();
  }

  /// Insert new user challenge
  Future<void> insertUserChallenge({
    required String userId,
    required Challenge challenge,
  }) async {
    await _client.from('user_challenges').insert({
      'user_id': userId,
      'challenge_id': challenge.id,
      'status': 'active',
      'progress': 0,
      'started_at': DateTime.now().toIso8601String(),
    });
  }

  /// Update user challenge progress
  Future<void> updateUserChallenge({
    required String userId,
    required Challenge challenge,
    required int progress,
    required bool isCompleted,
  }) async {
    await _client
        .from('user_challenges')
        .update({
          'progress': progress,
          'status': isCompleted ? 'completed' : 'active',
          if (isCompleted) 'completed_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('challenge_id', challenge.id);
  }

  /// Check if user already started a specific challenge
  Future<bool> hasUserStartedChallenge({
    required String userId,
    required String challengeId,
  }) async {
    final res = await _client
        .from('user_challenges')
        .select()
        .eq('user_id', userId)
        .eq('challenge_id', challengeId);

    return res.isNotEmpty;
  }

  /// Get specific user challenge by challenge ID
  Future<UserChallenge?> getUserChallengeById({
    required String userId,
    required String challengeId,
  }) async {
    final res = await _client
        .from('user_challenges')
        .select()
        .eq('user_id', userId)
        .eq('challenge_id', challengeId);

    if (res.isEmpty) return null;

    return UserChallenge.fromMap(Map<String, dynamic>.from(res.first));
  }
}
