import "package:alma_diary/features/challenges/engine/challenges_engine_v2.dart";

class ChallengeState {
  final List<Challenge> challenges;
  final List<UserChallenge> userChallenges;
  final Map<String, int> progressByChallenge;
  final Map<String, String> statusByChallenge;
  final Map<String, Challenge> challengeMap;

  final bool isLoading;
  final String? error;
  final String? userId;

  const ChallengeState({
    this.challenges = const [],
    this.userChallenges = const [],
    this.progressByChallenge = const {},
    this.statusByChallenge = const {},
    this.challengeMap = const {},
    this.isLoading = false,
    this.error,
    this.userId,
  });

  ChallengeState copyWith({
    List<Challenge>? challenges,
    List<UserChallenge>? userChallenges,
    Map<String, int>? progressByChallenge,
    Map<String, String>? statusByChallenge,
    Map<String, Challenge>? challengeMap,
    bool? isLoading,
    String? error,
    String? userId,
  }) {
    return ChallengeState(
      challenges: challenges ?? this.challenges,
      userChallenges: userChallenges ?? this.userChallenges,
      progressByChallenge:
          progressByChallenge ?? this.progressByChallenge,
      statusByChallenge:
          statusByChallenge ?? this.statusByChallenge,
      challengeMap: challengeMap ?? this.challengeMap,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userId: userId ?? this.userId,
    );
  }

  factory ChallengeState.initial() => const ChallengeState();
}