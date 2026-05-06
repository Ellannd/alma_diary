import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:alma_diary/features/journal/data/journal_service.dart';
import "package:alma_diary/state/reflections/reflection_state.dart";
import "package:alma_diary/state/reflections/reflection_controller.dart";
/// =========================
/// PROVIDERS
/// =========================
final journalServiceProvider = Provider<JournalService>((ref) {
  return JournalService.instance;
});

final reflectionControllerProvider =
    NotifierProvider<ReflectionController, ReflectionState>(
  ReflectionController.new,
);