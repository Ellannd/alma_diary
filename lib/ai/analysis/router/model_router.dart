import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/ai/analysis/domain/analysis_result.dart';

import 'package:alma_diary/ai/analysis/providers/huggingface_provider.dart';
import 'package:alma_diary/ai/analysis/providers/mock_provider.dart';
import 'package:alma_diary/ai/analysis/providers/gemini_provider.dart';

/// ModelRouter
///
/// Orquesta qué proveedor de IA usar.
/// Objetivos:
/// - fallback automático entre providers
/// - resiliencia en producción (evitar caídas totales)
/// - permitir cambio de modelo sin tocar la app
///
/// Orden típico:
/// 1. Primary (ej: Gemini)
/// 2. Secondary (ej: HuggingFace)
/// 3. Fallback seguro (Mock)
class ModelRouter {
  final GeminiProvider? gemini;
  final HuggingFaceProvider? huggingface;
  final MockProvider mock;

  ModelRouter({
    this.gemini,
    this.huggingface,
    required this.mock,
  });

  /// Punto único de entrada para análisis
  Future<AnalysisResult> analyze(String input) async {
    LogService.instance.info(
      'model.router.start',
      context: {
        'input_length': input.length,
      },
    );

    // 1. GEMINI (PRIMARY)
    if (gemini != null) {
      try {
        LogService.instance.info('model.router.try.gemini');

        final json = await gemini!.analyze(input);
        final result = AnalysisResult.fromJson(json);

        LogService.instance.info('model.router.success.gemini');
        return result;
      } catch (e, stack) {
        LogService.instance.error(
          'model.router.fail.gemini',
          error: e,
          stackTrace: stack,
        );
      }
    }

    // 2. HUGGING FACE (SECONDARY)
    if (huggingface != null) {
      try {
        LogService.instance.info('model.router.try.huggingface');

        final json = await huggingface!.analyze(input);
        final result = AnalysisResult.fromJson(json);

        LogService.instance.info('model.router.success.huggingface');
        return result;
      } catch (e, stack) {
        LogService.instance.error(
          'model.router.fail.huggingface',
          error: e,
          stackTrace: stack,
        );
      }
    }

    // 3. MOCK (FALLBACK SEGURO)
    LogService.instance.warning(
      'model.router.fallback.mock',
      context: {
        'reason': 'all_providers_failed',
      },
    );

    final json = await mock.analyze(input);
    return AnalysisResult.fromJson(json);
  }
}