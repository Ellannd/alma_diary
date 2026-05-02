import 'package:alma_diary/features/journal/data/journal_service.dart';

/// ReflectionController - State + Business Logic Layer
/// Responsibilities:
/// - State management (entries, isLoading, selectedEntry)
/// - Single source for journal entries (JournalService)
/// - Decryption wrapper
class ReflectionController {
  final JournalService _service = JournalService.instance;

  List<Map<String, dynamic>> entries = [];
  Map<String, dynamic>? selectedEntry;
  bool isLoading = false;
  String? error;

  /// Load all journal entries with decryption
  Future<void> loadEntries() async {
    isLoading = true;
    error = null;

    try {
      entries = await _service.getEntries(decrypt: true);
    } catch (e) {
      error = 'Error al cargar las entradas';
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  /// Load single entry by ID with decryption
  Future<void> loadEntry(String entryId) async {
    isLoading = true;
    error = null;

    try {
      selectedEntry = await _service.getEntryById(entryId, decrypt: true);
    } catch (e) {
      error = 'Error al cargar la entrada';
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  /// Clear selected entry
  void clearSelection() {
    selectedEntry = null;
  }

  /// Refresh entries
  Future<void> refresh() async {
    await loadEntries();
  }
}
