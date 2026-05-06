import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:alma_diary/state/readings/readings_state.dart";
import "package:alma_diary/features/readings/engine/readings_engine.dart";
import "package:alma_diary/features/readings/data/reading_repository.dart";


///////////////
/////PROVIDERS
///////////////
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
///////////////
/////CONTROLLER
///////////////
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
  // USER
  // =========================
  void setUser(String userId) {
    state = state.copyWith(userId: userId);
  }

  // =========================
  // LOAD
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
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error cargando lecturas',
      );
    }
  }

  // =========================
  // TOGGLE SAVE
  // =========================
  Future<void> toggleSave(String readingId) async {
    final userId = state.userId;
    if (userId == null) return;

    final savedIds = Set<String>.from(state.savedIds);

    try {
      if (savedIds.contains(readingId)) {
        await _repo.removeSavedReading(
          userId: userId,
          readingId: readingId,
        );
        savedIds.remove(readingId);
      } else {
        await _repo.saveReading(
          userId: userId,
          readingId: readingId,
        );
        savedIds.add(readingId);
      }

      state = state.copyWith(savedIds: savedIds);
    } catch (e) {
      state = state.copyWith(
        error: 'Error guardando lectura',
      );
    }
  }

  // =========================
  // HELPERS
  // =========================
  bool isSaved(String readingId) {
    return state.savedIds.contains(readingId);
  }

  String formatContent(String raw) {
    return raw.replaceAll(r'\n', '\n');
  }

  // =========================
  // AI PERSONALIZED
  // =========================
  Future<PersonalizedReading?> generatePersonalizedReading() async {
    try {
      final result = await _engine.generatePersonalizedReading();

      return PersonalizedReading(
        title: result['title'] ?? '',
        content: result['content'] ?? '',
        author: result['author'] ?? '',
        quote: result['quote'] ?? '',
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Error generando lectura personalizada',
      );
      return null;
    }
  }
}