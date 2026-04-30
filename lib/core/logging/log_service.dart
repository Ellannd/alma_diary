import "dart:async";
import 'package:flutter/foundation.dart';
import "package:alma_diary/core/logging/log_entry.dart";
import "package:alma_diary/core/logging/log_context.dart";
import "package:alma_diary/core/logging/crash/crash_reporter.dart";
import "package:alma_diary/core/logging/log_repository.dart";

class LogService {
  static final LogService instance = LogService._();
  LogService._();

  bool _initialized = false;
  int _logCounter = 0;


  final LogRepository _repository = LogRepository();

  final List<LogEntry> _entries = [];
  List<LogEntry> _pending = [];

  Future<void> init() async {
      if (_initialized) return;

    final logs = await _repository.loadLogs();
    _entries.addAll(logs);

    LogContext.instance.newSession(); // contexto global tipo Sentry

    unawaited(CrashReporter.instance.init());
    
    _initialized = true;

    info('LogService inicializado');
  }

  void _log(LogLevel level, String message,
      {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context,}) {

    if (level.index >= LogLevel.info.index) {
    LogContext.instance.addBreadcrumb(message);
  }

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      error: error?.toString(),
      stackTrace: stackTrace?.toString(),
      context: context ?? LogContext.instance.snapshot(),
    );
 // 1. guardar en memoria
    _entries.add(entry);
// 2. CONTROL DE MEMORIA 
    if (_entries.length > 500) {
      _entries.removeRange(0, 200);
    }

    _logCounter++;
    _pending.add(entry);
    // 3. persistencia por batch
    if (_logCounter % 10 == 0) {
    unawaited(_repository.saveLogs(_pending));
    _pending.clear();
  }
      
    // console
    debugPrint('[${level.name}] $message');

    // crash pipeline
    if (level == LogLevel.error || level == LogLevel.fatal) {
      unawaited(() async {
        try {
          await CrashReporter.instance.capture(entry);
        } catch (_) {}
      }());
    }
  }

  void info(
      String msg, {
      Map<String, dynamic>? context,
    }) =>
        _log(LogLevel.info, msg, context: context);

  void warning(
      String msg, {
      Map<String, dynamic>? context,
      Object? error,
      StackTrace? stackTrace,
    }) => _log(LogLevel.warning, msg,
        error: error,
        stackTrace: stackTrace,
        context: context,
      );

  void debug(
      String msg, {
      Map<String, dynamic>? context,
    }) =>
        _log(LogLevel.debug, msg, context: context);

  void error(
      String msg, {
      Object? error,
      StackTrace? stackTrace,
      Map<String, dynamic>? context,
    }) =>
        _log(
          LogLevel.error,
          msg,
          error: error,
          stackTrace: stackTrace,
          context: context,
        );

  void fatal(
      String msg, {
      Object? error,
      StackTrace? stackTrace,
      Map<String, dynamic>? context,
    }) =>
        _log(
          LogLevel.fatal,
          msg,
          error: error,
          stackTrace: stackTrace,
          context: context,
        );

 List<LogEntry> getFullLog() {
  return List.unmodifiable(_entries);
}

String exportLog() {
  return _entries.map((e) => e.toString()).join('\n');
}

Future<void> clear() async {
  _entries.clear();
  _pending.clear();
  _logCounter = 0;

  await _repository.clear();
}

}