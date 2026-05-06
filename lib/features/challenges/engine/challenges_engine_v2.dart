/// Challenges Engine V2 - Pure Business Logic Layer
/// 
/// Responsibilities (PURE - NO STATE, NO SUPABASE):
/// - Progress calculation
/// - State validation
/// - Transition rules
/// - Reward calculation
/// - Category logic
/// 
/// This engine is 100% STATELESS
library;

import 'package:alma_diary/features/notifications/engine/notifications_engine.dart';

/// Challenge states enum
enum ChallengeState {
  notStarted,
  active,
  completed,
  paused,
}

/// Challenge model - represents a challenge template from catalogue
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

/// UserChallenge model - tracks user's progress on a specific challenge
class UserChallenge {
  final String id;
  final String challengeId;
  final String status;
  final int progress;
  final DateTime? startedAt;
  final DateTime? completedAt;

  UserChallenge({
    required this.id,
    required this.challengeId,
    required this.status,
    required this.progress,
    this.startedAt,
    this.completedAt,
  });

  factory UserChallenge.fromMap(Map<String, dynamic> map) {
    return UserChallenge(
      id: map['id'].toString(),
      challengeId: map['challenge_id'].toString(),
      status: map['status']?.toString() ?? 'active',
      progress: (map['progress'] is int)
          ? map['progress']
          : int.tryParse(map['progress'].toString()) ?? 0,
      startedAt: map['started_at'] != null
          ? DateTime.tryParse(map['started_at'].toString())
          : null,
      completedAt: map['completed_at'] != null
          ? DateTime.tryParse(map['completed_at'].toString())
          : null,
    );
  }

  /// Get ChallengeState from status string
  ChallengeState get state {
    switch (status) {
      case 'completed':
        return ChallengeState.completed;
      case 'paused':
        return ChallengeState.paused;
      case 'active':
        return ChallengeState.active;
      default:
        return ChallengeState.notStarted;
    }
  }
}

/// Pure engine class - 100% stateless, no Supabase, no UI state
class ChallengesEngine {
  // Reference to notification engine for side effects (called by controller)
  AlmaNotificationEngine? _notificationEngine;

  ChallengesEngine({AlmaNotificationEngine? notificationEngine}) {
    _notificationEngine = notificationEngine;
  }

  /// Validate if a challenge can be started
  /// Returns: (isValid, errorMessage)
  (bool, String?) validateStart({
    required Challenge challenge,
    required List<UserChallenge> existingUserChallenges,
  }) {
    // Check if already started
    final alreadyStarted = existingUserChallenges.any(
      (uc) => uc.challengeId == challenge.id && uc.status == 'active',
    );
    
    if (alreadyStarted) {
      return (false, 'El desafío ya está activo');
    }

    // Check if already completed
    final alreadyCompleted = existingUserChallenges.any(
      (uc) => uc.challengeId == challenge.id && uc.status == 'completed',
    );
    
    if (alreadyCompleted) {
      return (false, 'El desafío ya ha sido completado');
    }

    // Validate challenge data
    if (challenge.id.isEmpty) {
      return (false, 'ID de desafío inválido');
    }

    if (challenge.difficulty < 1 || challenge.difficulty > 10) {
      return (false, 'Dificultad debe estar entre 1 y 10');
    }

    return (true, null);
  }

  /// Calculate progress based on increment
  int calculateProgress({
    required int currentProgress,
    required int increment,
  }) {
    final newProgress = currentProgress + increment;
    return newProgress.clamp(0, 100);
  }

  /// Check if progress indicates completion
  bool isProgressCompleted(int progress) {
    return progress >= 100;
  }

  /// Determine new status based on progress
  String determineStatus(int progress) {
    if (progress >= 100) {
      return 'completed';
    } else if (progress > 0) {
      return 'active';
    } else {
      return 'active';
    }
  }

  /// Calculate reward points (can include bonuses)
  int calculateReward({
    required Challenge challenge,
    required int finalProgress,
    required int durationDays,
  }) {
    if (finalProgress < 100) {
      return 0;
    }

    // Base reward
    int reward = challenge.rewardPoints;

    // Bonus for completing under expected duration
    if (durationDays < challenge.durationDays) {
      final bonusMultiplier = 1 + (challenge.durationDays - durationDays) * 0.1;
      reward = (reward * bonusMultiplier).round();
    }

    return reward;
  }

  /// Get category icon based on category name
  String getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'valentía':
      case 'valentia':
        return 'shield';
      case 'disciplina':
        return 'fitness';
      case 'mindfulness':
        return 'self_improvement';
      case 'emocional':
        return 'favorite';
      case 'creatividad':
        return 'palette';
      case 'relaciones':
        return 'people';
      default:
        return 'auto_awesome';
    }
  }

  /// Get category display name
  String getCategoryDisplayName(String category) {
    switch (category.toLowerCase()) {
      case 'valentía':
      case 'valentia':
        return 'Valentía';
      case 'disciplina':
        return 'Disciplina';
      case 'mindfulness':
        return 'Mindfulness';
      case 'emocional':
        return 'Emocional';
      case 'creatividad':
        return 'Creatividad';
      case 'relaciones':
        return 'Relaciones';
      default:
        return 'General';
    }
  }

  /// Build progress summary for a list of user challenges
  Map<String, dynamic> buildProgressSummary(List<UserChallenge> userChallenges) {
    int total = userChallenges.length;
    int completed = userChallenges.where((uc) => uc.status == 'completed').length;
    int active = userChallenges.where((uc) => uc.status == 'active').length;
    
    return {
      'total': total,
      'completed': completed,
      'active': active,
      'completionRate': total > 0 ? (completed / total * 100).round() : 0,
    };
  }

  /// Filter challenges by category
  List<Challenge> filterByCategory({
    required List<Challenge> challenges,
    required String category,
  }) {
    if (category.isEmpty || category.toLowerCase() == 'todas') {
      return challenges;
    }
    return challenges
        .where((c) => c.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Sort challenges by difficulty
  List<Challenge> sortByDifficulty({
    required List<Challenge> challenges,
    bool ascending = true,
  }) {
    final sorted = List<Challenge>.from(challenges);
    sorted.sort((a, b) => ascending 
        ? a.difficulty.compareTo(b.difficulty)
        : b.difficulty.compareTo(a.difficulty));
    return sorted;
  }

  /// Sort challenges by duration
  List<Challenge> sortByDuration({
    required List<Challenge> challenges,
    bool ascending = true,
  }) {
    final sorted = List<Challenge>.from(challenges);
    sorted.sort((a, b) => ascending
        ? a.durationDays.compareTo(b.durationDays)
        : b.durationDays.compareTo(a.durationDays));
    return sorted;
  }

  /// Notify challenge started (helper for controller)
  Future<void> notifyChallengeStarted({
    required String userId,
    required String challengeTitle,
  }) async {
    if (_notificationEngine != null) {
      await _notificationEngine!.notifyChallengeStarted(
        userId: userId,
        challengeTitle: challengeTitle,
      );
    }
  }

  /// Notify challenge completed (helper for controller)
  Future<void> notifyChallengeCompleted({
    required String userId,
    required String challengeTitle,
    required int rewardPoints,
  }) async {
    if (_notificationEngine != null) {
      await _notificationEngine!.notifyChallengeCompleted(
        userId: userId,
        challengeTitle: challengeTitle,
        rewardPoints: rewardPoints,
      );
    }
  }
}
