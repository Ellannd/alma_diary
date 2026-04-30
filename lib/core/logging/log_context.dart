class LogContext {
  static final LogContext instance = LogContext._();
  LogContext._();

  String? userId;
  String? sessionId;
  String? screen;

  final List<Map<String, dynamic>> _breadcrumbs = [];

  void setUser(String id) => userId = id;
  void setScreen(String name) => screen = name;

  void newSession() {
    sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _breadcrumbs.clear();
  }

  void addBreadcrumb(String message, {String? category}) {
    _breadcrumbs.add({
      'time': DateTime.now().toIso8601String(),
      'message': message,
      'category': category ?? 'ui',
    });

    if (_breadcrumbs.length > 50) {
      _breadcrumbs.removeAt(0);
    }
  }

  Map<String, dynamic> snapshot() => {
        'userId': userId,
        'sessionId': sessionId,
        'screen': screen,
        'breadcrumbs': List.unmodifiable(_breadcrumbs),
      };
}