class ChatConversation {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatConversation({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) =>
      ChatConversation(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        title: json['title'] as String? ?? 'Nueva conversación',
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  ChatConversation copyWith({String? title}) => ChatConversation(
    id: id,
    userId: userId,
    title: title ?? this.title,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  /// Formato legible para mostrar en el historial
  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(updatedAt);

    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inHours < 1) return 'Hace ${diff.inMinutes}m';
    if (diff.inDays < 1) return 'Hace ${diff.inHours}h';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';

    return '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}';
  }
}
