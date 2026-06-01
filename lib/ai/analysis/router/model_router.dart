import 'dart:async';
import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/ai/analysis/domain/analysis_result.dart';
import 'package:alma_diary/ai/analysis/providers/huggingface_provider.dart';
import 'package:alma_diary/ai/analysis/providers/mock_provider.dart';

class _ProviderResult {
  final AnalysisResult result;
  final String providerName;
  _ProviderResult(this.result, this.providerName);
}

class ModelRouter {
  final HuggingFaceProvider? huggingface;
  final MockProvider mock;

  String? _lastSuccessfulProvider;
  static const _huggingfaceTimeout = Duration(seconds: 30);

  ModelRouter({
    this.huggingface,
    required this.mock,
  });

  Future<AnalysisResult> analyze(String input) async {
    LogService.instance.info('model.router.start', context: {'input_length': input.length});

    if (_lastSuccessfulProvider == 'huggingface' && huggingface != null) {
      try {
        final json = await huggingface!.analyze(input).timeout(_huggingfaceTimeout);
        return AnalysisResult.fromJson(json);
      } catch (_) {
        _lastSuccessfulProvider = null;
      }
    }

    if (huggingface != null) {
      try {
        final json = await huggingface!.analyze(input).timeout(_huggingfaceTimeout);
        _lastSuccessfulProvider = 'huggingface';
        LogService.instance.info('model.router.success.huggingface');
        return AnalysisResult.fromJson(json);
      } catch (e, st) {
        LogService.instance.error('model.router.fail.huggingface', error: e, stackTrace: st);
      }
    }

    LogService.instance.warning('model.router.fallback.mock');
    final json = await mock.analyze(input);
    return AnalysisResult.fromJson(json);
  }
}