class Profile {
  final String displayName;
  final String email;
  final String? avatarUrl;
  final bool isOnboardingComplete;

  const Profile({
    required this.displayName,
    required this.email,
    this.avatarUrl,
    required this.isOnboardingComplete
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      displayName: map['display_name'] ?? 'Usuario',
      email: map['email'] ?? '',
      avatarUrl: map['avatar_url'],
      isOnboardingComplete: map['is_onboarding_complete'] ?? false,
    );
  }
  
}