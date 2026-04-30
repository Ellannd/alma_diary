import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import "package:alma_diary/core/logging/log_service.dart";

class AnalysisResult {
  final String sentiment;
  final double sentimentScore;
  final String archetype;
  final String reflection;
  final bool isFallback;
  final String? errorMessage;

  const AnalysisResult({
    required this.sentiment,
    required this.sentimentScore,
    required this.archetype,
    required this.reflection,
    this.isFallback = false,
    this.errorMessage,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      sentiment: (json['sentiment'] ?? 'neutral').toString(),
      sentimentScore: _parseScore(json['sentimentScore']),
      archetype: _normalizeArchetype(
        (json['archetype'] ?? 'The Mirror').toString(),
      ),
      reflection:
          (json['reflection'] ??
                  'Tu experiencia es válida y merece ser escuchada.')
              .toString(),
    );
  }

  static const AnalysisResult fallback = AnalysisResult(
    sentiment: 'neutral',
    sentimentScore: 0.5,
    archetype: 'The Mirror',
    reflection:
        'Tu experiencia fue guardada, incluso si el análisis no estuvo disponible.',
    isFallback: true,
    errorMessage:
        'El servicio de análisis no estuvo disponible. Tu entrada ha sido guardada.',
  );

  static double _parseScore(dynamic value) {
    if (value is num) {
      return value.toDouble().clamp(0.0, 1.0);
    }
    final parsed = double.tryParse(value?.toString() ?? '');
    return (parsed ?? 0.5).clamp(0.0, 1.0);
  }

  static String _normalizeArchetype(String value) {
    const allowed = {'The Mask', 'The Mirror', 'The Moon', 'The Shadow'};
    return allowed.contains(value) ? value : 'The Mirror';
  }
}

class GeminiAnalysisService {
  //TODO: Move _apiKey to secure storage and load it at runtime:
  static const String _apiKey = '';
  static const List<String> _modelList = [
    'gemini-1.5-flash',
    'gemini-1.5-flash-8b',
    'gemini-2.0-flash',
  ];
  static const String _systemPrompt =
      '''Eres el motor psicométrico de 'Alma'. Tu misión es transformar entradas de diario en metadatos. Debes analizar el texto y responder ÚNICAMENTE con un objeto JSON crudo (sin explicaciones) con esta estructura:
{
"sentiment": "una palabra descriptiva",
"sentimentScore": 0.0 a 1.0 (siendo 1.0 máxima claridad/paz),
"archetype": "The Mask", "The Shadow", "The Mirror" o "The Moon",
"reflection": "una frase breve y empática que valide el sentimiento del usuario"
}''';

  static const int _maxRetries = 3;
  static const List<int> _retryDelays = [1, 2, 4];

  Future<AnalysisResult> analyzeEntry(String text) async {
    if (text.trim().isEmpty || _apiKey.trim().isEmpty) {
      return AnalysisResult.fallback;
    }

    for (final modelName in _modelList) {
      final result = await _analyzeWithRetry(text, modelName);
      if (result != null) return result;
    }

    return AnalysisResult.fallback;
  }

  Future<AnalysisResult?> _analyzeWithRetry(
    String text,
    String modelName,
  ) async {
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        final result = await _analyzeWithModel(text, modelName);
        if (result != null) return result;
      } on ServerException catch (e) {
      final is503 = e.statusCode == 503;
      final shouldRetry = is503 && attempt < _maxRetries - 1;

      LogService.instance.warning(
        'gemini.analysis.retry_failed',
        context: {
          'model': modelName,
          'attempt': attempt + 1,
          'max_retries': _maxRetries,
          'status_code': e.statusCode,
          'retrying': shouldRetry,
          'error_message': e.message,
        },
      );

        if (shouldRetry) {
          final delay = _retryDelays[attempt];
          LogService.instance.info(
            'gemini.analysis.retry',
            context: {
              'model': modelName,
              'attempt': attempt + 1,
              'delay': delay,
            },
          );
          await Future.delayed(Duration(seconds: delay));
          continue;
        }

        return AnalysisResult(
          sentiment: 'neutral',
          sentimentScore: 0.5,
          archetype: 'The Mirror',
          reflection:
              'El servicio de análisis tuvo problemas. Tu entrada ha sido guardada.',
          isFallback: true,
          errorMessage:
              'Servicio no disponible temporalmente. Intenta más tarde.',
        );
      } catch (e) {
        LogService.instance.error(
          'gemini.analysis_failed',
          error: e,
          context: {
            'text': text,
          },
        );
        return null;
      }
    }
    return null;
  }

  Future<AnalysisResult?> _analyzeWithModel(
    String text,
    String modelName,
  ) async {
    try {
      final model = GenerativeModel(
        model: modelName,
        apiKey: _apiKey,
        requestOptions: const RequestOptions(apiVersion: 'v1'),
        generationConfig: GenerationConfig(
          temperature: 0.9,
          maxOutputTokens: 512,
        ),
      );

      LogService.instance.info(
        'gemini.analysis.call',
        context: {
          'model': modelName,
        },
      );

      final prompt = '$_systemPrompt\n\nEntrada de diario:\n$text';
      final response = await model.generateContent([Content.text(prompt)]);

      final rawText = response.text?.trim() ?? '{}';
      final cleanedText = _extractJson(rawText);
      final decodedJson = jsonDecode(cleanedText);

      if (decodedJson is! Map<String, dynamic>) {
        return null;
      }

      return AnalysisResult.fromJson(decodedJson);
    } catch (e) {
      LogService.instance.error(
        'gemini.analysis_failed',
        error: e,
        context: {
          'text': text,
          'model': modelName,
        },
      );
      rethrow;
    }
  }

  String _extractJson(String response) {
    var cleaned = response.trim();

    cleaned = cleaned
        .replaceAll(RegExp(r'^```json\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'^```'), '')
        .replaceAll(RegExp(r'```$'), '')
        .trim();

    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');

    if (start != -1 && end != -1 && end > start) {
      cleaned = cleaned.substring(start, end + 1);
    }

    return cleaned;
  }
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException(this.message, {this.statusCode});

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}
