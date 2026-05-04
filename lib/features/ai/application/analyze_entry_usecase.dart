import 'package:alma_diary/features/ai/analysis/domain/analysis_result.dart';
import 'package:alma_diary/features/ai/analysis/router/model_router.dart';
import 'package:alma_diary/core/logging/log_service.dart';

/// AnalyzeEntryUseCase
///
/// Capa de dominio (Clean Architecture).
///
/// Responsabilidades:
/// - Orquestar el flujo de análisis
/// - NO contiene lógica de IA
/// - NO conoce providers
/// - Solo coordina input → router → output
///
/// Esto permite:
/// - testabilidad
/// - reemplazo de IA sin tocar UI
/// - escalabilidad limpia
class AnalyzeEntryUseCase {
  final ModelRouter router;

  AnalyzeEntryUseCase({
    required this.router,
  });

  Future<AnalysisResult> call(String input) async {
    final trimmed = input.trim();

    LogService.instance.info(
      'usecase.analyze.start',
      context: {
        'input_length': trimmed.length,
      },
    );

    if (trimmed.isEmpty) {
      LogService.instance.warning(
        'usecase.analyze.empty_input',
      );

      return const AnalysisResult(
        sentiment: 'neutral',
        sentimentScore: 0.5,
        archetype: 'The Mirror',
        reflection: 'Tu experiencia es válida.',
      );
    }

    try {
      final result = await router.analyze(trimmed);

      LogService.instance.info(
        'usecase.analyze.success',
        context: {
          'sentiment': result.sentiment,
          'score': result.sentimentScore,
          'archetype': result.archetype,
        },
      );

      return result;
    } catch (e, stack) {
      LogService.instance.error(
        'usecase.analyze.failed',
        error: e,
        stackTrace: stack,
        context: {
          'input_length': trimmed.length,
        },
      );

      return const AnalysisResult(
        sentiment: 'neutral',
        sentimentScore: 0.5,
        archetype: 'The Mirror',
        reflection: 'No pude analizar esto ahora. Intenta nuevamente.',
      );
    }
  }
}