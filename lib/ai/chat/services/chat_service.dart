import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/ai/chat/domain/chat_message.dart';

class ChatService {
  final String _supabaseUrl;
  final String _supabaseAnonKey;
  final String _userId;

  // Historial en memoria — se limpia al cerrar el chat
  final List<ChatMessage> _history = [];

  // Timeout conservador para chat (más generoso que análisis)
  static const _timeout = Duration(seconds: 30);

  ChatService({
    required String supabaseUrl,
    required String supabaseAnonKey,
    required String userId,
  }) : _supabaseUrl = supabaseUrl,
       _supabaseAnonKey = supabaseAnonKey,
       _userId = userId;

  List<ChatMessage> get history => List.unmodifiable(_history);

  Future<ChatMessage> sendMessage(
    String userText, {
    required String conversationId,
  }) async {
    final userMessage = ChatMessage(
      content: userText.trim(),
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    _history.add(userMessage);

    LogService.instance.info(
      'chat.service.send',
      context: {'history_length': _history.length},
    );

    try {
      final uri = Uri.parse('$_supabaseUrl/functions/v1/chat');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_supabaseAnonKey',
            },
            body: jsonEncode({
              'user_id': _userId,
              'conversation_id': conversationId,
              // Solo enviamos user/assistant, sin system (lo construye el servidor)
              'history': _history
                  .where((m) => m.role != MessageRole.system)
                  .map((m) => m.toJson())
                  .toList(),
            }),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Edge Function error: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final reply = data['reply'] as String? ?? '';

      if (reply.isEmpty) throw Exception('Empty reply from model');

      final assistantMessage = ChatMessage(
        content: reply,
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
      );

      _history.add(assistantMessage);

      LogService.instance.info(
        'chat.service.reply',
        context: {'model': data['model']},
      );

      return assistantMessage;
    } catch (e, stack) {
      // Si falla, quitamos el mensaje del usuario del historial
      // para no corromper el contexto
      _history.removeLast();

      LogService.instance.error(
        'chat.service.error',
        error: e,
        stackTrace: stack,
      );

      rethrow;
    }
  }

  void restoreHistory(List<ChatMessage> messages) {
    _history
      ..clear()
      ..addAll(messages);
  }

  /// Limpia el historial (nueva conversación)
  void clearHistory() => _history.clear();
}
