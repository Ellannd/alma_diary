import 'dart:convert';
import 'package:alma_diary/core/logging/log_context.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alma_diary/core/logging/log_entry.dart';

class CrashReporter {
  static final CrashReporter instance = CrashReporter._();
  CrashReporter._();
  static const String _storageKey = 'alma_crash_logs';
  static const int _maxLocalCrashes = 10;

  final List<LogEntry> _buffer = [];

  /// Inicializa cargando crashes previos (opcional)
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw != null) {
      final List decoded = jsonDecode(raw);
      _buffer.addAll(
        decoded.map((e) => LogEntry.fromJson(e)),
      );
    }
  }

  /// Punto principal: registrar crash
  Future<void> capture(LogEntry entry) async {
    _addToBuffer(entry);

    await _saveLocally();

    // opcional: enviar a backend
    await _sendToRemote(entry);
  }

  /// Guarda en memoria (buffer limitado)
  void _addToBuffer(LogEntry entry) {
    _buffer.add(entry);

    if (_buffer.length > _maxLocalCrashes) {
      _buffer.removeAt(0);
    }
  }

  /// Persistencia local (offline-first)
  Future<void> _saveLocally() async {
    //final prefs = await SharedPreferences.getInstance();

   // final jsonList = _buffer.map((e) => e.toJson()).toList();
    //await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  /// Envío remoto 
  Future<void> _sendToRemote(LogEntry entry) async {
    try {
      final crashlytics = FirebaseCrashlytics.instance;

      // Adjuntar contexto del usuario
      final ctx = LogContext.instance.snapshot();
      if (ctx['userId'] != null) {
        await crashlytics.setUserIdentifier(ctx['userId']);
      }

      // Breadcrumbs como keys custom
      final breadcrumbs = ctx['breadcrumbs'] as List? ?? [];
      for (int i = 0; i < breadcrumbs.length; i++) {
        await crashlytics.setCustomKey(
          'breadcrumb_$i',
          breadcrumbs[i]['message']?.toString() ?? '',
        );
      }

      // Contexto adicional
      await crashlytics.setCustomKey('screen', ctx['screen'] ?? 'unknown');
      await crashlytics.setCustomKey('session_id', ctx['sessionId'] ?? '');
      await crashlytics.setCustomKey('log_level', entry.level.name);

      // Enviar error
      if (entry.stackTrace != null) {
        await crashlytics.recordError(
          entry.error ?? entry.message,
          StackTrace.fromString(entry.stackTrace!),
          reason: entry.message,
          fatal: entry.level == LogLevel.fatal,
        );
      } else {
        await crashlytics.log(entry.message);
      }
    } catch (_) {
      // nunca romper app por logging
    }
  }

    

  /// Obtener todos los crashes guardados
  List<LogEntry> getCrashes() => List.unmodifiable(_buffer);

  /// Limpiar crashes locales
  Future<void> clear() async {
    _buffer.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /// Exportar logs (debug / soporte)
  String export() {
    return _buffer.map((e) => e.toString()).join('\n\n');
  }
}