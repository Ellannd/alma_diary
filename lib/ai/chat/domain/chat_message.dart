// lib/ai/chat/domain/chat_message.dart

enum MessageRole { user, assistant, system }

class ChatMessage {
  final String content;
  final MessageRole role;
  final DateTime timestamp;

  const ChatMessage({
    required this.content,
    required this.role,
    required this.timestamp,
  });

  // Para enviar a la Edge Function
  Map<String, String> toJson() => {
    'role': role.name,
    'content': content,
  };

  // Para mostrar en UI
  bool get isUser      => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
}