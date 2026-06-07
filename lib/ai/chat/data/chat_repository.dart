// lib/ai/chat/data/chat_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alma_diary/ai/chat/domain/chat_conversation.dart';
import 'package:alma_diary/ai/chat/domain/chat_message.dart';
import 'package:alma_diary/core/constants.dart';
import 'package:alma_diary/core/logging/log_service.dart';

class ChatRepository {
  final SupabaseClient _client;

  ChatRepository(this._client);

  // ── Conversaciones ───────────────────────────────────────────

  /// Crea una conversación nueva y devuelve su id
  Future<ChatConversation> createConversation(String userId) async {
    final data = await _client
        .from('chat_conversations')
        .insert({'user_id': userId, 'title': 'Nueva conversación'})
        .select()
        .single();

    return ChatConversation.fromJson(data);
  }

  /// Lista todas las conversaciones del usuario, ordenadas por actividad
  Future<List<ChatConversation>> getConversations(String userId) async {
    final data = await _client
        .from('chat_conversations')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    return (data as List)
        .map((e) => ChatConversation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Carga los mensajes de una conversación
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    final data = await _client
        .from('chat_messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    return (data as List).map((e) {
      final map = e as Map<String, dynamic>;
      return ChatMessage(
        content: map['content'] as String,
        role: map['role'] == 'user' ? MessageRole.user : MessageRole.assistant,
        timestamp: DateTime.parse(map['created_at'] as String),
      );
    }).toList();
  }

  /// Actualiza el título de una conversación
  Future<void> updateTitle(String conversationId, String title) async {
    await _client
        .from('chat_conversations')
        .update({'title': title})
        .eq('id', conversationId);
  }

  /// Elimina una conversación (cascada borra los mensajes)
  Future<void> deleteConversation(String conversationId) async {
    await _client.from('chat_conversations').delete().eq('id', conversationId);
  }

  // ── Generación de título via Edge Function ───────────────────

  Future<String?> generateTitle(String firstMessage) async {
    try {
      final uri = Uri.parse('${EnvConfig.supabaseUrl}/functions/v1/chat-title');
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${EnvConfig.supabaseAnonKey}',
            },
            body: jsonEncode({'message': firstMessage}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['title'] as String?;
    } catch (e) {
      LogService.instance.error('chat.repo.generate_title', error: e);
      return null;
    }
  }
}
