import 'package:alma_diary/features/ai/analysis/domain/analysis_result.dart';
import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/features/ai/analysis/repository/ai_repository.dart';
import 'package:alma_diary/features/ai/analysis/router/model_router.dart';

/// AIServiceImpl
///
/// Implementación concreta del AIService.
/// Es el puente entre la capa CORE y la capa AI.
///
/// Responsabilidades:
/// - delegar al ModelRouter
/// - mantener independencia de providers
/// - centralizar logging de alto nivel
///
/// NO contiene lógica de IA.
/// NO decide modelos.
/// SOLO coordina ejecución.
class AIServiceImpl implements AIRepository {
  final ModelRouter router;

  AIServiceImpl({
    required this.router,
  });

  @override
  Future<AnalysisResult> analyze(String input) async {
    final trimmed = input.trim();

    LogService.instance.info(
      'ai.service.analyze.start',
      context: {
        'input_length': trimmed.length,
      },
    );

    if (trimmed.isEmpty) {
      LogService.instance.warning('ai.service.empty_input');

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
        'ai.service.analyze.success',
        context: {
          'sentiment': result.sentiment,
          'score': result.sentimentScore,
          'archetype': result.archetype,
        },
      );

      return result;
    } catch (e, stack) {
      LogService.instance.error(
        'ai.service.analyze.failed',
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
        reflection: 'No pude procesar esto ahora. Intenta nuevamente.',
      );
    }
  }
}