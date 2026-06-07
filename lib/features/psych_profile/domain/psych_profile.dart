class PsychProfile {
  final String id;
  final String userId;
  final String? attachmentStyle;
  final List<String> coreWounds;
  final List<String> emotionalPatterns;
  final List<String> currentFocus;
  final String? communicationStyle;
  final List<String> dominantEmotions;
  final List<String> psychologicalNeeds;
  final List<String> copingStrategies;
  final List<String> growthAreas;
  final String? narrativeSummary;
  final int? entryCountAtUpdate;
  final DateTime lastUpdated;
  final DateTime createdAt;

  const PsychProfile({
    required this.id,
    required this.userId,
    this.attachmentStyle,
    this.coreWounds = const [],
    this.emotionalPatterns = const [],
    this.currentFocus = const [],
    this.communicationStyle,
    this.dominantEmotions = const [],
    this.psychologicalNeeds = const [],
    this.copingStrategies = const [],
    this.growthAreas = const [],
    this.narrativeSummary,
    this.entryCountAtUpdate,
    required this.lastUpdated,
    required this.createdAt,
  });

  factory PsychProfile.fromJson(Map<String, dynamic> json) => PsychProfile(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    attachmentStyle: json['attachment_style'] as String?,
    coreWounds: _toList(json['core_wounds']),
    emotionalPatterns: _toList(json['emotional_patterns']),
    currentFocus: _toList(json['current_focus']),
    communicationStyle: json['communication_style'] as String?,
    dominantEmotions: _toList(json['dominant_emotions']),
    psychologicalNeeds: _toList(json['psychological_needs']),
    copingStrategies: _toList(json['coping_strategies']),
    growthAreas: _toList(json['growth_areas']),
    narrativeSummary: json['narrative_summary'] as String?,
    entryCountAtUpdate: json['entry_count_at_update'] as int?,
    lastUpdated: DateTime.parse(json['last_updated'] as String),
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  static List<String> _toList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.cast<String>();
    return [];
  }

  // Labels legibles para el UI
  String get attachmentStyleLabel => switch (attachmentStyle) {
    'secure' => 'Seguro',
    'anxious' => 'Ansioso',
    'avoidant' => 'Evitativo',
    'disorganized' => 'Desorganizado',
    _ => attachmentStyle ?? '—',
  };

  String get communicationStyleLabel => switch (communicationStyle) {
    'reflexivo' => 'Reflexivo',
    'impulsivo' => 'Impulsivo',
    'analítico' => 'Analítico',
    'emocional' => 'Emocional',
    'mixto' => 'Mixto',
    _ => communicationStyle ?? '—',
  };

  String get formattedDate {
    final d = lastUpdated;
    return '${d.day}/${d.month}/${d.year}';
  }
}
