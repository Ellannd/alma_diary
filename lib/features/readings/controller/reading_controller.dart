import '../data/reading_repository.dart';

/// ReadingController - State + Business Logic Layer
/// Responsibilities:
/// - State management (readings, savedIds, isLoading)
/// - Business logic
/// - Bridge between UI and Repository
class ReadingController {
  final ReadingRepository _repo;

  ReadingController(this._repo);

  List<Map<String, dynamic>> readings = [];
  Set<String> savedIds = {};
  bool isLoading = false;

  String? _userId;

  void setUser(String userId) {
    _userId = userId;
  }

  /// Cargar todo
  Future<void> load() async {
    if (_userId == null) return;

    isLoading = true;

    try {
      final data = await _repo.getReadings();
      final saved = await _repo.getSavedReadingIds(_userId!);

      readings = data;
      savedIds = saved;
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  /// Guardar / desguardar
  Future<void> toggleSave(String readingId) async {
    if (_userId == null) return;

    if (savedIds.contains(readingId)) {
      await _repo.removeSavedReading(
        userId: _userId!,
        readingId: readingId,
      );
      savedIds.remove(readingId);
    } else {
      await _repo.saveReading(
        userId: _userId!,
        readingId: readingId,
      );
      savedIds.add(readingId);
    }
  }

  bool isSaved(String readingId) {
    return savedIds.contains(readingId);
  }

  String getFormattedContent(Map<String, dynamic> reading) {
    final raw = reading['content'] ?? '';

    return raw.replaceAll(r'\n', '\n');
  }

  String getFormattedText(String reading) {
    final raw = reading;

    return raw.replaceAll(r'\n', '\n');
  }
}
