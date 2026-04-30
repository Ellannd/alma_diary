import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alma_diary/ai/engines/notifications_engine.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final String category;
  final int difficulty; // 1 - 10
  final int durationDays;
  final List<String> tags;
  final String? reflectionPrompt;
  final int rewardPoints;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.durationDays,
    required this.tags,
    required this.reflectionPrompt,
    required this.rewardPoints,
  });

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'].toString(),
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? 'general',

      difficulty: (map['difficulty'] is int)
          ? map['difficulty']
          : int.tryParse(map['difficulty'].toString()) ?? 1,

      durationDays: (map['duration_days'] is int)
          ? map['duration_days']
          : int.tryParse(map['duration_days'].toString()) ?? 1,

      tags: (map['tags'] is List)
          ? List<String>.from(map['tags'])
          : (map['tags'] is String)
              ? (map['tags'] as String)
                  .replaceAll('[', '')
                  .replaceAll(']', '')
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList()
              : [],

      reflectionPrompt: map['reflection_prompt']?.toString(),

      rewardPoints: (map['reward_points'] is int)
          ? map['reward_points']
          : int.tryParse(map['reward_points'].toString()) ?? 10,
    );
  }
}

class UserChallenge {
  final String id;
  final String challengeId;
  final String status;
  final int progress;

  UserChallenge({
    required this.id,
    required this.challengeId,
    required this.status,
    required this.progress,
  });

  factory UserChallenge.fromMap(Map<String, dynamic> map) {
    return UserChallenge(
      id: map['id'].toString(),
      challengeId: map['challenge_id'].toString(),
      status: map['status']?.toString() ?? 'active',
      progress: (map['progress'] is int)
          ? map['progress']
          : int.tryParse(map['progress'].toString()) ?? 0,
    );
  }
}

class ChallengesEngine {
  final SupabaseClient _client = Supabase.instance.client;

  /// 🔥 catálogo
  Future<List<Challenge>> fetchChallenges() async {
    final res = await _client
        .from('challenges')
        .select()
        .eq('active', true);

    return List<Map<String, dynamic>>.from(res)
        .map((e) => Challenge.fromMap(e))
        .toList();
  }

  /// 👤 progreso usuario
  Future<List<UserChallenge>> fetchUserChallenges(String userId) async {
    final res = await _client
        .from('user_challenges')
        .select()
        .eq('user_id', userId);

    return List<Map<String, dynamic>>.from(res)
        .map((e) => UserChallenge.fromMap(e))
        .toList();
  }

  /// 🚀 iniciar
  Future<void> startChallenge({
    required String userId,
    required Challenge challenge,
  }) async {
    // evitar duplicados
    final existing = await _client
        .from('user_challenges')
        .select()
        .eq('user_id', userId)
        .eq('challenge_id', challenge.id);

    if (existing.isNotEmpty) return;

    await _client.from('user_challenges').insert({
      'user_id': userId,
      'challenge_id': challenge.id,
      'status': 'active',
      'progress': 0,
      'started_at': DateTime.now().toIso8601String(),
    });

    /// 🔔 notificación
    final notif = AlmaNotificationEngine(_client);
    await notif.notifyChallengeStarted(
      userId: userId,
      challengeTitle: challenge.title,
    );
  }

  /// 📈 progreso
  Future<void> updateProgress({
    required String userId,
    required Challenge challenge,
    required int progress,
  }) async {
    final isCompleted = progress >= 100;

    await _client
        .from('user_challenges')
        .update({
          'progress': progress,
          'status': isCompleted ? 'completed' : 'active',
          if (isCompleted) 'completed_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('challenge_id', challenge.id);

    /// 🔔 completado
    if (isCompleted) {
      final notif = AlmaNotificationEngine(_client);
      await notif.notifyChallengeCompleted(
        userId: userId,
        challengeTitle: challenge.title,
        rewardPoints: challenge.rewardPoints,
      );
    }
  }
}