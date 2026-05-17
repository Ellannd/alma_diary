import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alma_diary/state/readings/readings_state.dart';
import 'package:alma_diary/features/readings/engine/readings_engine.dart';
import 'package:alma_diary/features/readings/data/reading_repository.dart';
import 'package:alma_diary/core/logging/log_service.dart';

final readingsRepositoryProvider = Provider((ref) => ReadingRepository());

final readingsEngineProvider = Provider<ReadingsEngine>((ref) {
  return ReadingsEngine('alma_biometric_pass');
});

final readingsControllerProvider =
    NotifierProvider<ReadingsController, ReadingsState>(
  ReadingsController.new,
);

class ReadingsController extends Notifier<ReadingsState> {
  late final ReadingRepository _repo;
  late final ReadingsEngine _engine;

  @override
  ReadingsState build() {
    _repo = ref.read(readingsRepositoryProvider);
    _engine = ref.read(readingsEngineProvider);

    return ReadingsState.initial();
  }

  // =========================
  // INIT USER
  // =========================
  void setUser (String userId) async {
    state = state.copyWith(userId: userId);
    await load();
  }

  // =========================
  // LOAD READINGS
  // =========================
  Future<void> load() async {
    final userId = state.userId;
    if (userId == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _repo.getReadings();
      final saved = await _repo.getSavedReadingIds(userId);

      state = state.copyWith(
        readings: data,
        savedIds: saved,
        isLoading: false,
      );
    } catch (e, st) {
      LogService.instance.error(
        'readings.load_failed',
        error: e,
        stackTrace: st,
      );

      state = state.copyWith(
        isLoading: false,
        error: 'Error cargando lecturas',
      );
    }
  }

  // =========================
  // SAVE / UNSAVE
  // =========================
  Future<void> toggleSave(String readingId) async {
    final userId = state.userId;
    if (userId == null) return;

    final saved = Set<String>.from(state.savedIds);

    try {
      if (saved.contains(readingId)) {
        await _repo.removeSavedReading(
          userId: userId,
          readingId: readingId,
        );
        saved.remove(readingId);
      } else {
        await _repo.saveReading(
          userId: userId,
          readingId: readingId,
        );
        saved.add(readingId);
      }

      state = state.copyWith(savedIds: saved);
    } catch (e, st) {
      LogService.instance.error(
        'readings.toggle_save_failed',
        error: e,
        stackTrace: st,
      );

      state = state.copyWith(error: 'Error guardando lectura');
    }
  }

  bool isSaved(String id) => state.savedIds.contains(id);

  // =========================
  // PERSONALIZED READING
  // =========================
  Future<Map<String, String>?> generatePersonalized() async {
    try {
      return await _engine.generatePersonalizedReading();
    } catch (e, st) {
      LogService.instance.error(
        'readings.personalized_failed',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}