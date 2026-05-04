import 'dart:convert';
import 'package:alma_diary/core/logging/log_service.dart';

/// ResponseParsing
///
/// Capa crítica para estabilidad del sistema IA.
///
/// Problema que resuelve:
/// - modelos devuelven JSON roto
/// - markdown accidental (```json)
/// - truncación de respuestas
/// - texto extra antes/después del JSON
///
/// Este parser intenta ser:
/// - tolerante (robustez)
/// - determinista (si falla -> null controlado)
/// - observable (logs claros)
class ResponseParser {
  ResponseParser._();

  /// Extrae JSON de una respuesta de IA de forma segura.
  ///
  /// Retorna:
  /// - Map si es válido
  /// - null si no se puede parsear
  static Map<String, dynamic> extractJsonSafe(String raw) {
  try {
    final cleaned = _clean(raw);

    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');

    if (start == -1 || end == -1 || end <= start) {
      LogService.instance.error('parser.no_json_found');
      throw Exception('No valid JSON found in response');
    }

    final jsonString = cleaned.substring(start, end + 1);
    final decoded = jsonDecode(jsonString);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception('Invalid JSON type');
  } catch (e, stack) {
    LogService.instance.error(
      'parser.failed',
      error: e,
      stackTrace: stack,
    );

    throw Exception('Parsing failed');
  }
}

  /// Limpia artefactos comunes de modelos LLM
  static String _clean(String input) {
    return input
        .replaceAll(RegExp(r'```json', multiLine: true), '')
        .replaceAll(RegExp(r'```', multiLine: true), '')
        .trim();
  }
}