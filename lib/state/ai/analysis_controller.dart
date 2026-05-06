import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:alma_diary/state/ai/analysis_state.dart";
import "package:alma_diary/ai/analysis/repository/ai_repository.dart";
import "package:alma_diary/state/ai/ai_provider.dart";
import "package:alma_diary/core/logging/log_service.dart";

final analysisControllerProvider =
    NotifierProvider<AnalysisController, AnalysisState>(
  AnalysisController.new,
);

class AnalysisController extends Notifier<AnalysisState> {
  late final AIRepository _aiRepository;

  @override
  AnalysisState build() {
    _aiRepository = ref.read(aiServiceProvider); // inyectado
    return AnalysisState.initial();
  }

  /// =========================
  /// ANALYZE
  /// =========================
  Future<void> analyze(String text) async {
    state = state.copyWith(
      loading: true,
      error: null,
    );

    LogService.instance.info(
      'controller.analyze.start',
      context: {'input_length': text.length},
    );

    try {
      final res = await _aiRepository.analyze(text);

      state = state.copyWith(
        result: res,
        loading: false,
      );

      LogService.instance.info(
        'controller.analyze.success',
        context: {
          'sentiment': res.sentiment,
          'score': res.sentimentScore,
          'archetype': res.archetype,
        },
      );
    } catch (e, stack) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );

      LogService.instance.error(
        'controller.analyze.failed',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// =========================
  /// RESET
  /// =========================
  void reset() {
    state = AnalysisState.initial();
  }
}