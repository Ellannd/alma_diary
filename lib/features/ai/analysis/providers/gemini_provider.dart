import 'dart:async';
import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/features/ai/analysis/prompt/alma_prompt_builder.dart';
import 'package:alma_diary/features/ai/analysis/utils/response_parsing.dart';

class GeminiProvider {
  final String apiKey;
  final List<String> modelList;

  GenerativeModel? _model;

  GeminiProvider({
    required this.apiKey,
    this.modelList = const [
      'gemini-2.5-flash',
      'gemini-2.5-flash-lite',
    ],
  });

  Future<Map<String, dynamic>> analyze(String input) async {
    LogService.instance.debug(
      'gemini.provider.start',
      context: {
        'input_length': input.length,
      },
    );

    final model = await _getModel();

    final prompt = AlmaPromptBuilder.build(input);

    LogService.instance.debug(
      'gemini.prompt.built',
      context: {
        'prompt_length': prompt.length,
      },
    );

    final response = await model
        .generateContent([Content.text(prompt)])
        .timeout(const Duration(seconds: 15));

    final text = _extractText(response);

    LogService.instance.debug(
      'gemini.raw.response',
      context: {
        'length': text.length,
        'preview': text.substring(0, text.length > 120 ? 120 : text.length),
      },
    );

    final json = ResponseParser.extractJsonSafe(text);

    LogService.instance.info(
      'gemini.provider.success',
      context: {
        'keys': json.keys.toList(),
      },
    );

    return json;
  }

  Future<GenerativeModel> _getModel() async {
    if (_model != null) return _model!;

    for (final modelName in modelList) {
      try {
        LogService.instance.info(
          'gemini.model.initializing',
          context: {'model': modelName},
        );

        final model = GenerativeModel(
          model: modelName,
          apiKey: apiKey,
          generationConfig:  GenerationConfig(
            temperature: 0.7,
            maxOutputTokens: 512,
          ),
          requestOptions: const RequestOptions(
            apiVersion: 'v1',
          ),
        );

        _model = model;

        LogService.instance.info(
          'gemini.model.ready',
          context: {'model': modelName},
        );

        return _model!;
      } catch (e, stack) {
        LogService.instance.error(
          'gemini.model.init_failed',
          error: e,
          stackTrace: stack,
          context: {'model': modelName},
        );

        _model = null;
        continue;
      }
    }

    throw Exception('No available Gemini models');
  }

  String _extractText(GenerateContentResponse response) {
    final buffer = StringBuffer();

    for (final candidate in response.candidates) {
      final content = candidate.content;

      for (final part in content.parts) {
        if (part is TextPart) {
          buffer.write(part.text);
        }
      }
    }

    final text = buffer.toString().trim();

    if (text.isEmpty) {
      LogService.instance.error(
        'gemini.empty_response',
      );
      throw Exception('Empty response from Gemini');
    }

    return text;
  }

  void reset() {
    LogService.instance.warning('gemini.model.reset');
    _model = null;
  }
}