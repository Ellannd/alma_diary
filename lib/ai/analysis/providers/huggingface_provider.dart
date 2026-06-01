import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/ai/analysis/prompt/alma_prompt_builder.dart';
import 'package:alma_diary/ai/analysis/utils/response_parsing.dart';

/// HuggingFaceProvider
///
/// Antes: llamaba directo a HF Inference API (exponía HF_API_KEY en el cliente).
/// Ahora: delega a la Supabase Edge Function `analyze-entry`,
///        que guarda la key en secrets del servidor.
///
/// Contrato de salida: igual que antes → Map<String, dynamic> con
/// { sentiment, sentimentScore, archetype, reflection }
/// → compatible con AnalysisResult.fromJson() sin cambios.
class HuggingFaceProvider {
  final SupabaseClient _client;

  /// Nombre de la Edge Function desplegada en Supabase
  final String _functionName;

  HuggingFaceProvider({
    SupabaseClient? client,
    String functionName = 'analyze-entry',
  })  : _client = client ?? Supabase.instance.client,
        _functionName = functionName;

  Future<Map<String, dynamic>> analyze(String input) async {
    LogService.instance.debug(
      'hf.provider.start',
      context: {'input_length': input.length},
    );

    // Construimos el prompt exactamente igual que antes
    // para que la Edge Function reciba el mismo texto estructurado
    final prompt = AlmaPromptBuilder.build(input);

    LogService.instance.debug(
      'hf.prompt.built',
      context: {'prompt_length': prompt.length},
    );

    try {
      LogService.instance.info(
        'hf.edge.invoke',
        context: {'function': _functionName},
      );

      // El SDK adjunta el JWT del usuario automáticamente
      final response = await _client.functions
          .invoke(
            _functionName,
            body: {'text': prompt},
          )
          .timeout(const Duration(seconds: 30));

      final payload = response.data as Map<String, dynamic>;

      // La Edge Function devuelve { data: { sentiment, sentimentScore, ... } }
      final data = payload['data'];
      if (data == null) {
        throw Exception('Edge Function devolvió data nula');
      }

      // data puede venir como Map o como String (si el modelo devuelve JSON en texto)
      final Map<String, dynamic> result = switch (data) {
        Map<String, dynamic> m => m,
        String s               => ResponseParser.extractJsonSafe(s),
        _                      => throw Exception('Tipo de data inesperado: ${data.runtimeType}'),
      };

      LogService.instance.info(
        'hf.edge.success',
        context: {'keys': result.keys.toList()},
      );

      return result;
    } on FunctionException catch (e) {
      final msg = _parseErrorMessage(e.details) ?? 'Error en Edge Function';
      LogService.instance.error(
        'hf.edge.function_exception',
        error: e,
        context: {'status': e.status, 'message': msg},
      );
      throw Exception('HuggingFace Edge Function error (${ e.status}): $msg');
    } catch (e, stack) {
      LogService.instance.error(
        'hf.edge.failed',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  String? _parseErrorMessage(dynamic details) {
    if (details is Map) return details['error']?.toString();
    if (details is String) {
      try {
        final decoded = jsonDecode(details) as Map;
        return decoded['error']?.toString();
      } catch (_) {
        return details;
      }
    }
    return null;
  }
}