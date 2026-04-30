
class AlmaNotification {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final String color;
  final String action;
  final String? actionRoute;
  final bool isRead;
  final DateTime createdAt;

  AlmaNotification({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.action,
    this.actionRoute,
    required this.isRead,
    required this.createdAt,
  });

  factory AlmaNotification.fromMap(Map<String, dynamic> map) {
    return AlmaNotification(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      icon: map['icon'] ?? 'notifications',
      color: map['color'] ?? 'orange',
      action: map['action'] ?? 'Abrir',
      actionRoute: map['action_route'],
      isRead: map['is_read'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap(String userId) {
    return {
      'user_id': userId,
      'title': title,
      'subtitle': subtitle,
      'icon': icon,
      'color': color,
      'action': action,
      'action_route': actionRoute,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AlmaNotification copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? icon,
    String? color,
    String? action,
    String? actionRoute,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AlmaNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      action: action ?? this.action,
      actionRoute: actionRoute ?? this.actionRoute,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}