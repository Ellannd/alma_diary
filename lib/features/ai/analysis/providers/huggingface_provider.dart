import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/features/ai/analysis/prompt/alma_prompt_builder.dart';
import 'package:alma_diary/features/ai/analysis/utils/response_parsing.dart';

class HuggingFaceProvider {
  final String apiKey;

  /// Lista de modelos en orden de prioridad (fallback automático)
  final List<String> modelList;

  /// Endpoint base (permite cambiar infra sin romper código)
  final String baseUrl;

  HuggingFaceProvider({
    required this.apiKey,
    this.modelList = const [
      'HuggingFaceH4/zephyr-7b-beta',
      'mistralai/Mistral-7B-Instruct-v0.2',
      'google/gemma-2b-it',
    ],
    this.baseUrl = 'https://api-inference.huggingface.co/models',
  });

  Future<Map<String, dynamic>> analyze(String input) async {
    LogService.instance.debug(
      'hf.provider.start',
      context: {
        'input_length': input.length,
      },
    );

    final prompt = AlmaPromptBuilder.build(input);

    LogService.instance.debug(
      'hf.prompt.built',
      context: {
        'prompt_length': prompt.length,
      },
    );

    for (final model in modelList) {
      try {
        LogService.instance.info(
          'hf.model.try',
          context: {'model': model},
        );

        final response = await _callModel(model, prompt)
            .timeout(const Duration(seconds: 20));

        final rawText = _extractText(response);

        LogService.instance.debug(
          'hf.raw.response',
          context: {
            'model': model,
            'length': rawText.length,
            'preview': rawText.substring(
              0,
              rawText.length > 120 ? 120 : rawText.length,
            ),
          },
        );

        final json = ResponseParser.extractJsonSafe(rawText);

        LogService.instance.info(
          'hf.model.success',
          context: {
            'model': model,
            'keys': json.keys.toList(),
          },
        );

        return json;
      } catch (e, stack) {
        LogService.instance.error(
          'hf.model.failed',
          error: e,
          stackTrace: stack,
          context: {'model': model},
        );

        continue;
      }
    }

    throw Exception('No HuggingFace models succeeded');
  }

  Future<dynamic> _callModel(String model, String prompt) async {
    final uri = Uri.parse('$baseUrl/$model');

    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "inputs": prompt,
        "parameters": {
          "temperature": 0.7,
          "max_new_tokens": 512,
          "return_full_text": false,
        },
        "options": {
          "wait_for_model": true,
        }
      }),
    );

    LogService.instance.debug(
      'hf.http.response',
      context: {
        'status': res.statusCode,
        'model': model,
      },
    );

    if (res.statusCode != 200) {
      throw Exception('HF error ${res.statusCode}: ${res.body}');
    }

    return jsonDecode(res.body);
  }

  String _extractText(dynamic response) {
    try {
      if (response is List && response.isNotEmpty) {
        final first = response.first;

        if (first is Map && first.containsKey('generated_text')) {
          return (first['generated_text'] as String).trim();
        }
      }

      if (response is Map && response.containsKey('generated_text')) {
        return (response['generated_text'] as String).trim();
      }

      throw Exception('Unknown HF response format');
    } catch (e) {
      LogService.instance.error(
        'hf.parse.error',
        error: e,
        context: {
          'response_type': response.runtimeType.toString(),
        },
      );
      rethrow;
    }
  }
}

