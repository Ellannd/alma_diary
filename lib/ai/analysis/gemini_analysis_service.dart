import 'dart:convert';
import 'dart:async';
import "package:flutter_dotenv/flutter_dotenv.dart";
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:crypto/crypto.dart';
import 'package:alma_diary/core/logging/log_service.dart';

class AnalysisResult {
  final String sentiment;
  final double sentimentScore;
  final String archetype;
  final String reflection;

  const AnalysisResult({
    required this.sentiment,
    required this.sentimentScore,
    required this.archetype,
    required this.reflection,
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
  static const String _systemPrompt =
      '''Eres Alma.

RESPONDE SOLO JSON VÁLIDO.

Reglas estrictas:
- No uses markdown
- No uses ``` 
- No expliques nada
- No agregues texto fuera del JSON
- Si no puedes cumplir, responde igualmente un JSON válido

Formato exacto:
{
  "sentiment": "string",
  "sentimentScore": number,
  "archetype": "string",
  "reflection": "string"
}''';

  static const List<String> _modelList = [
    'gemini-1.5-pro',
    'gemini-1.5-flash-lite',
     'gemini-1.0-flash',
  ];

  static const int _maxRetries = 3;
  static const List<int> _retryDelays = [2, 4, 8];
  static const Duration _debounceDelay = Duration(milliseconds: 800);
  static const int _requestsPerMinute = 15;

  final Map<String, AnalysisResult> _cache = {};
  final List<DateTime> _requestTimestamps = [];
  GenerativeModel? _model;
  DateTime? _lastRequestTime;
  String? _lastInputHash;

  String _hashInput(String text) {
    final bytes = utf8.encode(text.trim().toLowerCase());
    return md5.convert(bytes).toString();
  }

  bool _isRateLimited() {
    final now = DateTime.now();
    _requestTimestamps.removeWhere((t) => now.difference(t).inMinutes > 1);
    return _requestTimestamps.length >= _requestsPerMinute;
  }

  void _recordRequest() {
    _requestTimestamps.add(DateTime.now());
  }

  void _resetModel() {
    _model = null;
  }

  Future<GenerativeModel> _getModel() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    for (final modelName in _modelList) {
      try {
        final candidate = GenerativeModel(
          model: modelName,
          apiKey: apiKey,
          requestOptions: const RequestOptions(apiVersion: 'v1'),
          generationConfig: GenerationConfig(
            temperature: 0.4,
            maxOutputTokens: 400,
          ),
        );

        // VALIDACIÓN REAL (clave)
        final testResponse = await candidate.generateContent([
          Content.text("ping")
        ]).timeout(const Duration(seconds: 5));

        if (testResponse.text != null) {
          _model = candidate;

          LogService.instance.info(
            'gemini.model.ready',
            context: {
              'model': modelName,
            },
          );

          return _model!;
        }
      } catch (e, stack) {
        LogService.instance.warning(
          'gemini.model.failed',
          error: e,
          stackTrace: stack,
          context: {
            'model': modelName,
          },
        );
      }
    }

    throw Exception('No hay modelos funcionales');
  }

Future<AnalysisResult> analyzeEntry(String text) async {
  print("🟢 [ANALYZE ENTRY] START");
  final apiKey = dotenv.env['GEMINI_API_KEY'];
  print("🔑 GEMINI API KEY: $apiKey");
  print("📥 RAW INPUT: $text");

  final trimmed = text.trim();
  print("✂️ TRIMMED INPUT: $trimmed");

  if (trimmed.isEmpty) {
    print("⚠️ EMPTY INPUT → returning fallback");
    return const AnalysisResult(
      sentiment: 'neutral',
      sentimentScore: 0.5,
      archetype: 'The Mirror',
      reflection: 'Tu experiencia es válida.',
    );
  }

  final inputHash = _hashInput(trimmed);

  print("🔑 INPUT HASH: $inputHash");
  print("📦 CACHE SIZE: ${_cache.length}");

  //  CACHE HIT REAL
  final cached = _cache[inputHash];
  if (cached != null) {
    print("⚡ CACHE HIT → returning cached result");

    LogService.instance.debug(
      'gemini.cache.hit',
      context: {
        'hash': inputHash,
        'cache_size': _cache.length,
      },
    );
    return cached;
  }

  print("🧊 CACHE MISS");

  // DEBOUNCE GLOBAL (no por hash exacto)
  if (_lastRequestTime != null) {
    final elapsed = DateTime.now().difference(_lastRequestTime!);

    print("⏱️ TIME SINCE LAST REQUEST: ${elapsed.inMilliseconds}ms");

    if (elapsed < _debounceDelay) {
      final wait = _debounceDelay - elapsed;

      print("🕒 DEBOUNCE ACTIVE → WAITING ${wait.inMilliseconds}ms");

      LogService.instance.debug(
        'gemini.debounce.wait',
        context: {'wait_ms': wait.inMilliseconds},
      );

      await Future.delayed(wait);
    }
  }

  // RATE LIMIT (NO BLOQUEANTE)
  print("📊 CHECKING RATE LIMIT...");

  if (_isRateLimited()) {
    print("🚫 RATE LIMITED TRIGGERED");

    LogService.instance.warning(
      'gemini.rate_limited',
      context: {
        'cache_size': _cache.length,
      },
    );

    return const AnalysisResult(
      sentiment: 'neutral',
      sentimentScore: 0.5,
      archetype: 'The Mirror',
      reflection: 'Estoy procesando mucho ahora. Intenta en un momento.',
    );
  }

  _lastRequestTime = DateTime.now();
  print("🚀 REQUEST TIMESTAMP UPDATED");

  // RETRIES + TIMEOUT
  for (int attempt = 0; attempt < _maxRetries; attempt++) {
    print("🧪 ATTEMPT START: $attempt");

    try {
      final result = await _attemptAnalysis(trimmed)
          .timeout(const Duration(seconds: 10));

      print("📨 RESPONSE RECEIVED FROM GEMINI");
      print("📦 RESULT NULL? ${result == null}");

      if (result != null) {
        print("💾 CACHING RESULT FOR HASH");

        _cache[inputHash] = result;

        if (_cache.length > 100) {
          print("🧹 CACHE LIMIT REACHED → CLEANING OLDEST");
          _cache.remove(_cache.keys.first);
        }

        _recordRequest();

        LogService.instance.info(
          'gemini.analysis.success',
          context: {
            'attempt': attempt,
            'cache_size': _cache.length,
          },
        );

        print("✅ ANALYSIS SUCCESS RETURNING RESULT");
        return result;
      }

      print("⚠️ GEMINI RETURNED NULL RESULT");
    } catch (e, stack) {
      print("❌ GEMINI ANALYSIS FAILED");
      print("🧨 ERROR: $e");
      print("📚 STACKTRACE: $stack");
      print("🔁 ATTEMPT: $attempt");
      print("📏 INPUT LENGTH: ${trimmed.length}");

      final errorMsg = e.toString().toLowerCase();

      final isRetryable =
          errorMsg.contains('429') ||
          errorMsg.contains('rate') ||
          errorMsg.contains('503') ||
          errorMsg.contains('unavailable') ||
          errorMsg.contains('timeout');

      print("🔍 ERROR CLASSIFICATION");
      print("↪️ retryable: $isRetryable");

      LogService.instance.error(
        'gemini.analysis.failed',
        error: e,
        stackTrace: stack,
        context: {
          'attempt': attempt,
          'text_length': trimmed.length,
          'error_type': e.runtimeType.toString(),
          'is_retryable': isRetryable,
        },
      );

      if (isRetryable && attempt < _maxRetries - 1) {
        final delay = _retryDelays[attempt];

        print("⏳ RETRYING IN ${delay}s");
        print("🔄 RESETTING MODEL");

        await Future.delayed(Duration(seconds: delay));
        _resetModel();
        continue;
      }

      print("🛑 NO MORE RETRIES → BREAK");
      break;
    }
  }

  print("❌ FINAL FALLBACK RETURNED");

  return const AnalysisResult(
    sentiment: 'neutral',
    sentimentScore: 0.5,
    archetype: 'The Mirror',
    reflection: 'No pude analizar ahora. ¿Qué emoción es más fuerte?',
  );
}

 Future<AnalysisResult> _attemptAnalysis(String text) async {
    final model = await _getModel();

    final prompt = '$_systemPrompt\n\nEntrada:\n$text';

    final response = await model.generateContent([
      Content.text(prompt),
    ]);

    final raw = response.text;

    if (raw == null || raw.trim().isEmpty) {
      throw Exception("Empty Gemini response");
    }
      print("📩 RAW GEMINI RESPONSE:");
   print(response.text);
    final cleaned = extractJsonSafe(raw.trim());

    Map<String, dynamic> decoded;

    try {
      decoded = jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (e) {
      print("❌ GEMINI RAW OUTPUT:\n$raw");
      print("❌ EXTRACTED JSON:\n$cleaned");
      rethrow;
    }

    return AnalysisResult.fromJson(decoded);
  }

  String extractJsonSafe(String input) {
    final start = input.indexOf('{');
    final end = input.lastIndexOf('}');

    if (start == -1 || end == -1 || end <= start) {
      throw Exception("No JSON found in response");
    }

    return input.substring(start, end + 1);
  }
}
