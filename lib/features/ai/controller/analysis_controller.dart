import 'package:alma_diary/features/ai/analysis/domain/analysis_result.dart';
import 'package:alma_diary/features/ai/analysis/repository/ai_repository.dart';
import 'package:alma_diary/core/logging/log_service.dart';
import 'package:flutter/material.dart';

/// Controller de análisis emocional.
///
/// Responsabilidad:
/// - manejar estado de UI
/// - coordinar llamadas a AIRepository
/// - exponer data lista para UI
class AnalysisController extends ChangeNotifier{
  final AIRepository aiRepository;

  AnalysisController(this.aiRepository);

  AnalysisResult? _result;
  bool _loading = false;
  String? _error;

  AnalysisResult? get result => _result;
  bool get loading => _loading;
  String? get error => _error;

  /// Ejecuta análisis completo
  Future<void> analyze(String text) async {
    _setLoading(true);
    _setError(null);
    notifyListeners();

    LogService.instance.info(
      'controller.analyze.start',
      context: {'input_length': text.length},
    );

    try {
      final res = await aiRepository.analyze(text);

      _result = res;

      LogService.instance.info(
        'controller.analyze.success',
        context: {
          'sentiment': res.sentiment,
          'score': res.sentimentScore,
          'archetype': res.archetype,
        },
      );
    } catch (e, stack) {
      _error = e.toString();

      LogService.instance.error(
        'controller.analyze.failed',
        error: e,
        stackTrace: stack,
      );
    } finally {
      _setLoading(false);
      notifyListeners();

    }
  }

  void reset() {
    _result = null;
    _error = null;
    _loading = false;
    notifyListeners();

  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();

  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }
}