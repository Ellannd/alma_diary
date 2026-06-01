import "package:alma_diary/ai/analysis/domain/archetype.dart";

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
    case 'vacío':
      return PainPoint.vacio;
    case 'confusion':
      return PainPoint.confusion;
    case 'cansancio':
      return PainPoint.cansancio;
    default:
      return null;
  }
}

// Añadir al parser:
HopefulGoal? _parseHopefulGoal(String? value) {
  switch (value) {
    case 'paz':
      return HopefulGoal.paz;
    case 'orden':
      return HopefulGoal.orden;
    case 'acompañamiento':
      return HopefulGoal.companero;
    case 'crecimiento':
      return HopefulGoal.crecimiento; 
    default:
      return null;
  }
}

Archetype? _parseArchetype(String? value) {
  if (value == null) return null;
  return Archetype.fromString(value);
}
