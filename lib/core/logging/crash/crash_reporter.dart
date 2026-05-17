import 'dart:convert';
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

  /// Envío remoto (placeholder para Supabase / Firebase / API)
  Future<void> _sendToRemote(LogEntry entry) async {
    try {
      // TODO: reemplazar con backend real
      // ejemplo:
      // await supabase.from('crashes').insert(entry.toJson());

      return;
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