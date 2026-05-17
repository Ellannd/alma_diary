import "enums.dart";

class Profile {
  final String displayName;
  final String email;
  final String? avatarUrl;
  final bool isOnboardingComplete;

  final EmotionalState? emotionalState;
  final PainPoint? painPoint;
  final HopefulGoal? hopefulGoal;
  final String? mainChallenge;
  final String? preferredLanguage;
  final int? stressLevel;
  final String? sleepQuality;
  final Archetype? archetype;
  final List<String> painNodes;

  const Profile({
    required this.displayName,
    required this.email,
    this.avatarUrl,
    required this.isOnboardingComplete,

    this.emotionalState,
    this.painPoint,
    this.hopefulGoal,
    this.mainChallenge,
    this.preferredLanguage,
    this.stressLevel,
    this.sleepQuality,
    this.archetype,
    this.painNodes = const [],
  });

factory Profile.fromMap(Map<String, dynamic> map) {
  return Profile(
    displayName: map['full_name'] ?? map['name'] ?? 'Usuario',
    email: map['email'] ?? '',
    avatarUrl: map['avatar_url'],
    isOnboardingComplete: map['is_onboarding_complete'] ?? false,

    emotionalState: _parseEmotionalState(map['emotional_state']),
    painPoint: _parsePainPoint(map['pain_point']),
    hopefulGoal: _parseHopefulGoal(map['hopeful_goal']),
    mainChallenge: map['main_challenge'],
    preferredLanguage: map['preferred_language'],
    stressLevel: map['stress_level'],
    sleepQuality: map['sleep_quality'],
    archetype: _parseArchetype(map['archetype']),
    painNodes: List<String>.from(map['pain_nodes'] ?? []),
  );
}
  
}

EmotionalState? _parseEmotionalState(String? value) {
  switch (value) {
    case 'abrumado':
      return EmotionalState.abrumado;
    case 'nublado':
      return EmotionalState.nublado;
    case 'agotado':
      return EmotionalState.agotado;
    case 'inspirado':
      return EmotionalState.inspirado;
    default:
      return null;
  }
}

PainPoint? _parsePainPoint(String? value) {
  switch (value) {
    case 'estres':
      return PainPoint.estres;
    case 'vacio':
      return PainPoint.vacio;
    case 'confusion':
      return PainPoint.confusion;
    default:
      return null;
  }
}

HopefulGoal? _parseHopefulGoal(String? value) {
  switch (value) {
    case 'paz':
      return HopefulGoal.paz;
    case 'orden':
      return HopefulGoal.orden;
    case 'companero':
      return HopefulGoal.companero;
    default:
      return null;
  }
}

Archetype? _parseArchetype(String? value) {
  switch (value) {
    case 'The Mask':
      return Archetype.theMask;
    case 'The Mirror':
      return Archetype.theMirror;
    case 'The Moon':
      return Archetype.theMoon;
    case 'The Shadow':
      return Archetype.theShadow;
    case 'The Self':
      return Archetype.theSelf;
    default:
      return null;
  }
}