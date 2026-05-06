import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:alma_diary/state/ai/analysis_controller.dart";
import "package:alma_diary/state/ai/analysis_state.dart";

final analysisControllerProvider =
    NotifierProvider<AnalysisController, AnalysisState>(
  AnalysisController.new,
);