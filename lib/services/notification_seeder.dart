import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationSeeder {
  final SupabaseClient _client;

  NotificationSeeder(this._client);

  Future<void> generateDailyQuote(String userId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final existing = await _client
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('type', 'daily_quote')
        .gte('created_at', today.toIso8601String());

    if (existing.isNotEmpty) return;

    final quotesResponse = await _client.from('quotes').select();
    final quotes = List<Map<String, dynamic>>.from(quotesResponse);

    if (quotes.isEmpty) return;

    final seed = int.parse('${userId.hashCode}${today.day}');
    final quote = quotes[seed % quotes.length];

    await _client.from('notifications').insert({
      'user_id': userId,
      'type': 'daily_quote',
      'title': 'Frase del día',
      'subtitle': quote['text'],
      'icon': 'psychology',
      'color': 'purple',
      'action': 'Leer',
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}