// lib/features/psych_profile/state/psych_profile_controller.dart

import 'package:alma_diary/state/profile/profile_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alma_diary/features/psych_profile/domain/psych_profile.dart';
import 'package:alma_diary/features/psych_profile/data/psych_profile_repository.dart';
import 'package:alma_diary/core/logging/log_service.dart';

// ── Estado ───────────────────────────────────────────────────────

class PsychProfileState {
  final PsychProfile? profile;
  final List<PsychProfile> history;
  final bool isLoading;
  final bool isGenerating;
  final String? error;

  const PsychProfileState({
    this.profile,
    this.history = const [],
    this.isLoading = false,
    this.isGenerating = false,
    this.error,
  });

  PsychProfileState copyWith({
    PsychProfile? profile,
    List<PsychProfile>? history,
    bool? isLoading,
    bool? isGenerating,
    String? error,
    bool clearError = false,
  }) => PsychProfileState(
    profile: profile ?? this.profile,
    history: history ?? this.history,
    isLoading: isLoading ?? this.isLoading,
    isGenerating: isGenerating ?? this.isGenerating,
    error: clearError ? null : error ?? this.error,
  );

  bool get hasProfile => profile != null;
  bool get hasError => error != null;
  bool get hasHistory => history.isNotEmpty;
}

// ── Notifier ─────────────────────────────────────────────────────

class PsychProfileNotifier extends Notifier<PsychProfileState> {
  late PsychProfileRepository _repo;

  static const int _regenerateThreshold = 5; // cada 5 entradas

  @override
  PsychProfileState build() {
    final user = ref.watch(currentUserProvider);

    _repo = PsychProfileRepository(Supabase.instance.client);

    if (user != null) {
      Future.microtask(() => _loadProfile(user.id));
    }

    return const PsychProfileState();
  }

  // ── Carga inicial ────────────────────────────────────────────

  Future<void> _loadProfile(String userId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final profile = await _repo.getProfile(userId);
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e, stack) {
      LogService.instance.error(
        'psych_profile.load',
        error: e,
        stackTrace: stack,
      );
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Llamar tras guardar una journal entry ────────────────────
  // Llama a este método desde tu JournalController después de guardar

  Future<void> onEntryAdded() async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    try {
      final count = await _repo.entriesSinceLastUpdate(userId);

      LogService.instance.info(
        'psych_profile.entries_since_update',
        context: {'count': count},
      );

      if (count >= _regenerateThreshold) {
        await _generate(userId);
      }
    } catch (e) {
      LogService.instance.error('psych_profile.on_entry_added', error: e);
    }
  }

  // ── Generación manual (botón en UI) ─────────────────────────

  Future<void> generateNow() async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;
    await _generate(userId);
  }

  Future<void> _generate(String userId) async {
    if (state.isGenerating) return;

    state = state.copyWith(isGenerating: true, clearError: true);

    LogService.instance.info(
      'psych_profile.generating',
      context: {'user_id': userId},
    );

    final profile = await _repo.generateProfile(userId);

    if (profile != null) {
      LogService.instance.info('psych_profile.generated');
      state = state.copyWith(profile: profile, isGenerating: false);
    } else {
      state = state.copyWith(
        isGenerating: false,
        error: 'No se pudo generar el perfil. Inténtalo más tarde.',
      );
    }
  }

  // ── Historial ────────────────────────────────────────────────

  Future<void> loadHistory() async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    try {
      final history = await _repo.getProfileHistory(userId);
      state = state.copyWith(history: history);
    } catch (e) {
      LogService.instance.error('psych_profile.load_history', error: e);
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

// ── Provider ─────────────────────────────────────────────────────

final psychProfileProvider =
    NotifierProvider<PsychProfileNotifier, PsychProfileState>(
      PsychProfileNotifier.new,
    );
