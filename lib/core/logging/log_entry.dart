enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

extension LogLevelPriority on LogLevel {
  int get priority {
    switch (this) {
      case LogLevel.debug:
        return 0;
      case LogLevel.info:
        return 1;
      case LogLevel.warning:
        return 2;
      case LogLevel.error:
        return 3;
      case LogLevel.fatal:
        return 4;
    }
  }
}

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;

  final String? error;
  final String? stackTrace;

  /// Contexto tipo Sentry (INMUTABLE)
  final Map<String, dynamic> context;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
    this.context = const {},
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'level': level.name,
        'message': message,
        'error': error,
        'stackTrace': stackTrace,
        'context': context,
      };

  factory LogEntry.fromJson(Map<String, dynamic> json) => LogEntry(
        timestamp: DateTime.parse(json['timestamp'] as String),
        level: LogLevel.values.firstWhere(
          (e) => e.name == json['level'],
          orElse: () => LogLevel.info,
        ),
        message: json['message'] as String,
        error: json['error'] as String?,
        stackTrace: json['stackTrace'] as String?,
        context: (json['context'] as Map?)?.cast<String, dynamic>() ?? {},
      );

  @override
  String toString() {
    return '''
[$timestamp] [${level.name.toUpperCase()}] $message
Context: $context
${error != null ? 'Error: $error' : ''}
${stackTrace != null ? 'Stack: $stackTrace' : ''}
''';
  }
}