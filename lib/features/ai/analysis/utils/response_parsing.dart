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

  /// Extrae JSON de una respuesta de IA de forma segura. Hay que corroborar la respuesta en json que devuelve un modelo en dado caso, para hacer modificaciones a este método.
  ///
  /// Retorna:
  /// - Map si es válido
  /// - null si no se puede parsear
static Map<String, dynamic> extractJsonSafe(String raw) {
  try {
    LogService.instance.debug(
      'parser.raw_input',
      context: {
        'length': raw.length,
        'preview': raw.length > 120 ? raw.substring(0, 120) : raw,
      },
    );

    // 1. limpiar <think> y ruido del modelo
    final cleaned = _clean(raw);

    LogService.instance.debug(
      'parser.cleaned',
      context: {
        'length': cleaned.length,
      },
    );

    // 2. extraer SOLO el contenido JSON real
    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');

    if (start == -1 || end == -1 || end <= start) {
      LogService.instance.error(
        'parser.no_json_found',
        context: {
          'cleaned_preview': cleaned.length > 200
              ? cleaned.substring(0, 200)
              : cleaned,
        },
      );
      throw Exception('No valid JSON found in response');
    }

    final jsonString = cleaned.substring(start, end + 1);

    LogService.instance.debug(
      'parser.extracted_json',
      context: {
        'json': jsonString.length > 300
            ? jsonString.substring(0, 300)
            : jsonString,
      },
    );

    // 3. decode seguro
    final decoded = jsonDecode(jsonString);

    if (decoded is Map<String, dynamic>) {
      LogService.instance.info('parser.success');
      return decoded;
    }

    LogService.instance.error(
      'parser.invalid_type',
      context: {'type': decoded.runtimeType.toString()},
    );

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
  /// Limpia respuestas de texto
  static String _clean(String input) {
    return input
        // 1. eliminar reasoning models (<think>)
        .replaceAll(
          RegExp(r'<think>.*?</think>', dotAll: true),
          '',
        )

        // 2. eliminar markdown code blocks
        .replaceAll('```json', '')
        .replaceAll('```', '')

        // 3. eliminar saltos de formato raros
        .replaceAll(RegExp(r'^\s+|\s+$'), '')

        // 4. normalizar espacios
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')

        .trim();
  }
}