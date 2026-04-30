import 'package:supabase_flutter/supabase_flutter.dart';

/// =====================================================
/// ALMA NOTIFICATION ENGINE
/// Sistema centralizado de notificaciones de la app
///
/// Responsabilidades:
/// - Crear notificaciones (quotes, challenges, insights)
/// - Evitar duplicados
/// - Consultar no leídas
/// - Marcar como leídas
/// =====================================================
class AlmaNotificationEngine {
  final SupabaseClient _client;

  AlmaNotificationEngine(this._client);

  // =====================================================
  // 1. DAILY QUOTE NOTIFICATION
  // =====================================================
  Future<void> generateDailyQuote(String userId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    /// Evita duplicados por día + tipo
    final existing = await _client
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('type', 'daily_quote')
        .gte('created_at', today.toIso8601String());

    if (existing.isNotEmpty) return;

    ///  Obtener quotes reales de la DB
    final quotesResponse = await _client.from('quotes').select();
    final quotes = List<Map<String, dynamic>>.from(quotesResponse);

    if (quotes.isEmpty) return;

    ///  selección determinística (no random puro)
    final seed = userId.hashCode + today.day;
    final quote = quotes[seed % quotes.length];

    /// Insert notification
    await _client.from('notifications').insert({
      'user_id': userId,
      'type': 'daily_quote',
      'title': 'Frase del día',
      'subtitle': quote['text'],
      'icon': 'psychology',
      'color': 'purple',
      'action': 'Leer',
      'action_route': null,
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // =====================================================
  // 2. CHALLENGE STARTED
  // =====================================================
  Future<void> notifyChallengeStarted({
    required String userId,
    required String challengeTitle,
  }) async {
    await _client.from('notifications').insert({
      'user_id': userId,
      'type': 'challenge_started',
      'title': 'Nuevo desafío iniciado',
      'subtitle': challengeTitle,
      'icon': 'emoji_events',
      'color': 'amber',
      'action': 'Ver desafío',
      'action_route': '/challenges',
      'is_read': false,
    });
  }

  // =====================================================
  // 3. CHALLENGE COMPLETED
  // =====================================================
  Future<void> notifyChallengeCompleted({
    required String userId,
    required String challengeTitle,
    required int rewardPoints,
  }) async {
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
  }

  // =====================================================
  //  4. INSIGHT / PATRONES DEL USUARIO
  // =====================================================
  Future<void> notifyInsight({
    required String userId,
    required String title,
    required String message,
  }) async {
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
  }

  // =====================================================
  // 🔹 5. MARK AS READ
  // =====================================================
  Future<void> markAsRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  // =====================================================
  //  6. UNREAD COUNT (para badge en campana)
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
  // 7. GET USER NOTIFICATIONS
  // =====================================================
  Future<List<Map<String, dynamic>>> fetchUserNotifications(String userId) async {
    final response = await _client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> trackLoginEvent(String userId) async {
    await _client.from('events').insert({
      'user_id': userId,
      'type': 'auth',
      'event': 'login',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> trackOnboardingEvent(String userId) async {
    await _client.from('events').insert({
      'user_id': userId,
      'type': 'onboarding',
      'event': 'completed',
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}