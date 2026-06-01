import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alma_diary/core/result/validation_result.dart';

/// =====================================================
/// ALMA NOTIFICATION ENGINE
/// =====================================================
class AlmaNotificationEngine {
  final SupabaseClient _client;

  AlmaNotificationEngine(this._client);

  // =====================================================
  // 1. DAILY QUOTE NOTIFICATION
  // =====================================================
  Future<ValidationResult> generateDailyQuote(String userId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final existing = await _client
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('type', 'daily_quote')
          .gte('created_at', today.toIso8601String());

      if ((existing as List).isNotEmpty) {
        return ValidationResult.fail('Daily quote already exists');
      }

      final quotesResponse = await _client.from('quotes').select();
      final quotes = List<Map<String, dynamic>>.from(quotesResponse);

      if (quotes.isEmpty) {
        return ValidationResult.fail('No quotes available');
      }

      final seed = userId.hashCode + today.day;
      final quote = quotes[seed % quotes.length];

      await _client.from('notifications').insert({
        'user_id': userId,
        'type': 'daily_quote',
        'title': 'Frase del día',
        'subtitle': quote['text'],
        'icon': 'psychology',
        'color': 'purple',
        'action': 'Marcar como leída',
        'action_route': null,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      return ValidationResult.ok();
    } catch (e) {
      return ValidationResult.fail('generateDailyQuote error: $e');
    }
  }

  // =====================================================
  // 2. CHALLENGE STARTED
  // =====================================================
  Future<ValidationResult> notifyChallengeStarted({
    required String userId,
    required String challengeTitle,
  }) async {
    try {
      await _client.from('notifications').insert({
        'user_id': userId,
        'type': 'challenge_started',
        'title': 'Nuevo desafío iniciado 🎯',
        'subtitle': challengeTitle,
        'icon': 'emoji_events',
        'color': 'amber',
        'action': 'Ver desafío 🔍',
        'action_route': '/challenges',
        'is_read': false,
      });

      

      return ValidationResult.ok();
    } catch (e) {
      return ValidationResult.fail('notifyChallengeStarted error: $e');
    }
  }

  // =====================================================
  // 3. CHALLENGE COMPLETED
  // =====================================================
  Future<ValidationResult> notifyChallengeCompleted({
    required String userId,
    required String challengeTitle,
    required int rewardPoints,
  }) async {
    try {
      await _client.from('notifications').insert({
        'user_id': userId,
        'type': 'challenge_completed',
        'title': 'Desafío completado 🎉',
        'subtitle': '$challengeTitle (+$rewardPoints pts)',
        'icon': 'celebration',
        'color': 'green',
        'action': 'Ver progreso',
        'action_route': '/trajectory',
        'is_read': false,
      });

      return ValidationResult.ok();
    } catch (e) {
      return ValidationResult.fail('notifyChallengeCompleted error: $e');
    }
  }

  // =====================================================
  // 4. INSIGHT
  // =====================================================
  Future<ValidationResult> notifyInsight({
    required String userId,
    required String title,
    required String message,
  }) async {
    try {
      await _client.from('notifications').insert({
        'user_id': userId,
        'type': 'insight',
        'title': title,
        'subtitle': message,
        'icon': 'psychology',
        'color': 'orange',
        'action': 'Explorar',
        'action_route': '/trajectory',
        'is_read': false,
      });

      return ValidationResult.ok();
    } catch (e) {
      return ValidationResult.fail('notifyInsight error: $e');
    }
  }

  // =====================================================
  // 5. MARK AS READ
  // =====================================================
  Future<ValidationResult> markAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

      return ValidationResult.ok();
    } catch (e) {
      return ValidationResult.fail('markAsRead error: $e');
    }
  }

    Future<ValidationResult> markAllAsRead(String userId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);

      return ValidationResult.ok();
    } catch (e) {
      return ValidationResult.fail('markAllAsRead error: $e');
    }
  }

  // =====================================================
  // 6. UNREAD COUNT
  // =====================================================
  Future<int> getUnreadCount(String userId) async {
    final response = await _client
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);

    return (response as List).length;
  }

  // =====================================================
  // 7. FETCH NOTIFICATIONS
  // =====================================================
  Future<List<Map<String, dynamic>>> fetchUserNotifications(
    String userId,
  ) async {
    final response = await _client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // =====================================================
  // 8. EVENTS
  // =====================================================
  Future<ValidationResult> trackLoginEvent(String userId) async {
    try {
      await _client.from('events').insert({
        'user_id': userId,
        'type': 'auth',
        'event': 'login',
        'created_at': DateTime.now().toIso8601String(),
      });

      return ValidationResult.ok();
    } catch (e) {
      return ValidationResult.fail('trackLoginEvent error: $e');
    }
  }

  Future<ValidationResult> trackOnboardingEvent(String userId) async {
      try {
        await _client.from('events').insert({
          'user_id': userId,
          'type': 'onboarding',
          'event': 'completed',
          'created_at': DateTime.now().toIso8601String(),
        });

        return ValidationResult.ok();
      } catch (e) {
        return ValidationResult.fail('trackOnboardingEvent error: $e');
      }
    }

    Future<ValidationResult> generateDailyReminder(String userId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final settings = await _client
          .from('notification_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      final enabled = settings?['daily_reminder_enabled'] as bool? ?? false;

      if (!enabled) {
        return ValidationResult.fail('Daily reminder disabled');
      }

      final existing = await _client
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('type', 'daily_reminder')
          .gte('created_at', today.toIso8601String());

      if (existing.isNotEmpty) {
        return ValidationResult.fail('Already exists today');
      }

      await _client.from('notifications').insert({
        'user_id': userId,
        'type': 'daily_reminder',
        'title': 'Tu momento contigo',
        'subtitle': 'Escribe tu entrada de hoy',
        'icon': 'schedule',
        'color': 'purple',
        'action': 'Escribir ahora',
        'action_route': '/create',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      return ValidationResult.ok();
    } catch (e) {
      return ValidationResult.fail('Error generating reminder: $e');
    }
  }

Future<void> sendPush({
  required String userId,
  required String title,
  required String body,
}) async {
  final response = await _client.functions.invoke(
    'send-notification',  
    body: {
      'userId': userId,
      'title': title,
      'body': body,
    },
  );

  if (response.status != 200) {
    throw Exception('sendPush failed (${response.status}): ${response.data}');
  }
}
}