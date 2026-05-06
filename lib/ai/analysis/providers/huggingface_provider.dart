import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/ai/analysis/prompt/alma_prompt_builder.dart';
import 'package:alma_diary/ai/analysis/utils/response_parsing.dart';

import "package:flutter_dotenv/flutter_dotenv.dart";

class HuggingFaceProvider {
  final String apiKey;

  /// Lista de modelos en orden de prioridad (fallback automático, disponibles a tráves de HF con Inference API disponible)
  final List<String> modelList;

  /// Endpoint base (permite cambiar infra sin romper código)
  final String baseUrl;

  HuggingFaceProvider({
    required this.apiKey,
    this.modelList = const [
      "Qwen/Qwen3-8B:nscale",
      "Qwen/Qwen3-1.7B:featherless-ai",
      'meta-llama/Llama-3.1-8B-Instruct:novita',
      "Qwen/Qwen3-32B:groq",
      "openai/gpt-oss-120b:groq",
    ],
    this.baseUrl = 'https://router.huggingface.co/v1/chat/completions',
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
        final apiKey = dotenv.get("HF_API_KEY");

      //Estructura del prompt a la IA
        final res = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": model,
        "messages": [
          {
            "role": "system",
            "content": "Return ONLY valid JSON. No <think>. No explanation."
          },
          {
            "role": "user",
            "content": prompt
          }
        ],
        "temperature": 0.2,
        "max_tokens": 300
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
  //Este médodo primeramente extrae el message del json completo
  String _extractText(Map<String, dynamic> response) {
      try {
        return response['choices'][0]['message']['content'] ?? '';
      } catch (e) {
        throw Exception('Invalid HF response structure');
      }
    }
}

