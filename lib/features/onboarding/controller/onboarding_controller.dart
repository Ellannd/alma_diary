import "package:alma_diary/features/profile/data/profile_repository.dart";

class OnboardingController {
  final ProfileRepository _repo;

  OnboardingController(this._repo);

  Future<void> completeOnboarding({
    required String emotionalState,
    required String painPoint,
    required String hopefulGoal,
    String? mainChallenge,
    String? preferredLanguage,
    int? stressLevel,
    String? sleepQuality,
    String? name,
  }) async {
    await _repo.completeOnboarding(
      emotionalState: emotionalState,
      painPoint: painPoint,
      hopefulGoal: hopefulGoal,
      mainChallenge: mainChallenge,
      preferredLanguage: preferredLanguage,
      stressLevel: stressLevel,
      sleepQuality: sleepQuality,
      name: name,
    );
  }

  Future<Map<String, dynamic>?> loadProfile(String userId) {
    return _repo.getUserProfile(userId);
  }

  Future<void> ensureProfile(String userId) {
    return _repo.ensureProfileExists(userId);
  }

  
}