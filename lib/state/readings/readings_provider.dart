import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:alma_diary/state/readings/readings_state.dart";
import "package:alma_diary/state/readings/readings_controller.dart";
import "package:alma_diary/features/readings/engine/readings_engine.dart";
import "package:alma_diary/features/readings/data/reading_repository.dart";

final readingsControllerProvider =
    NotifierProvider<ReadingsController, ReadingsState>(
  ReadingsController.new,
);

final readingsRepositoryProvider = Provider<ReadingRepository>((ref) {
  return ReadingRepository();
});

final readingsEngineProvider = Provider<ReadingsEngine>((ref) {
  return ReadingsEngine('your_passphrase');
});