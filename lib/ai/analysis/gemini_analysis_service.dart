import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
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
      '''Eres Alma, una guía de introspección. Analiza el sentimiento y el arquetipo (The Mask, The Mirror, The Moon, The Shadow). Escribe una "reflection" de 3-4 frases que valide la emoción. Responde SOLO EN JSON: {"sentiment": "...", "sentimentScore": 0.0-1.0, "archetype": "...", "reflection": "..."}''';

  static const List<String> _modelList = [
    'gemini-2.0-flash',
    'gemini-2.5-flash',
    'gemini-2.5-flash-lite',
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
    if (_model != null) return _model!;
    final prefs = await SharedPreferences.getInstance();
    final apiKey =
        prefs.getString('gemini_api_key') ??
        'AIzaSyBUNG-9VwOV8S5kZ6CdTDhUfatVmyVu4Ug';

    for (final modelName in _modelList) {
      try {
        _model = GenerativeModel(
          model: modelName,
          apiKey: apiKey,
          requestOptions: const RequestOptions(apiVersion: 'v1'),
          generationConfig: GenerationConfig(
            temperature: 0.9,
            maxOutputTokens: 512,
          ),
        );
              LogService.instance.info(
        'gemini.model.initialized',
        context: {
          'model': modelName,
        },
      );
        return _model!;
      } catch (e, stack) {
        _model = null;

        LogService.instance.error(
          'gemini.model.init_failed',
          error: e,
          stackTrace: stack,
          context: {
            'model': modelName,
          },
        );
      }
    }
    throw Exception('Sin modelos disponibles');
  }

  Future<AnalysisResult> analyzeEntry(String text) async {
    if (text.trim().isEmpty) {
      return const AnalysisResult(
        sentiment: 'neutral',
        sentimentScore: 0.5,
        archetype: 'The Mirror',
        reflection: 'Tu experiencia es válida.',
      );
    }

    final inputHash = _hashInput(text);
    LogService.instance.debug(
      'gemini.cache.hit',
      context: {
        'hash': inputHash,
        'cache_size': _cache.length,
        'layer': 'memory',
      },
    );

    if (_lastInputHash == inputHash && _lastRequestTime != null) {
      final elapsed = DateTime.now().difference(_lastRequestTime!);
      if (elapsed < _debounceDelay) {
        await Future.delayed(_debounceDelay - elapsed);
      }
    }

    if (_isRateLimited()) {
      LogService.instance.warning(
        'gemini.rate_limited',
        context: {
          'cache_size': _cache.length,
        },
      );
      await Future.delayed(const Duration(seconds: 5));
    }

    _lastInputHash = inputHash;
    _lastRequestTime = DateTime.now();

    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        final result = await _attemptAnalysis(text);
        if (result != null) {
          _cache[inputHash] = result;
          _recordRequest();
          return result;
        }
      } catch (e) {
        final errorMsg = e.toString().toLowerCase();
        final is429 = errorMsg.contains('429') || errorMsg.contains('rate');
        final is503 =
            errorMsg.contains('503') || errorMsg.contains('unavailable');

        if ((is429 || is503) && attempt < _maxRetries - 1) {
          final delay = _retryDelays[attempt];
          LogService.instance.warning(
            'gemini.retry',
            context: {
              'attempt': attempt,
              'delay': delay,
              'error': errorMsg,
            },
          );
          await Future.delayed(Duration(seconds: delay));
          _resetModel();
          continue;
        }
        LogService.instance.error(
          'gemini.analysis_failed',
          error: e,
          context: {
            'text': text,
          },
        );
      }
      break;
    }

    return const AnalysisResult(
      sentiment: 'neutral',
      sentimentScore: 0.5,
      archetype: 'The Mirror',
      reflection: 'No pude analizar ahora. ¿Qué emoción es más fuerte?',
    );
  }

  Future<AnalysisResult?> _attemptAnalysis(String text) async {
    final model = await _getModel();
    final prompt = '$_systemPrompt\n\nEntrada:\n$text';
    final response = await model.generateContent([Content.text(prompt)]);

    if (response.text == null || response.text!.isEmpty) {
      return null;
    }

    final cleaned = _cleanResponse(response.text!.trim());
    final decoded = jsonDecode(cleaned);

    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    return AnalysisResult.fromJson(decoded);
  }

  String _cleanResponse(String response) {
    return response
        .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^```\s*', multiLine: true), '')
        .replaceAll(RegExp(r'\s*```$', multiLine: true), '')
        .trim();
  }
}
