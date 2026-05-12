import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:alma_diary/features/challenges/challenge_repository_old.dart";
import "package:alma_diary/features/challenges/engine/challenges_engine_v2.dart";
import "package:alma_diary/state/challenges/challenge_controller.dart";
import "package:alma_diary/state/challenges/challenge_state.dart";

final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  return ChallengeRepository();
});

final challengesEngineProvider = Provider<ChallengesEngine>((ref) {
  return ChallengesEngine();
});

final challengeControllerProvider =
    NotifierProvider<ChallengeController, ChallengeState>(
  ChallengeController.new,
);