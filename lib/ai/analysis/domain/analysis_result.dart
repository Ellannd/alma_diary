class AnalysisResult {
  final String sentiment;
  final double sentimentScore;
  final String archetype;
  final String reflection;

  const AnalysisResult({
    required this.sentiment,
    required this.sentimentScore,
    required this.archetype,
    required this.reflection,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      sentiment: (json['sentiment'] ?? 'neutral').toString(),
      sentimentScore: _parseScore(json['sentimentScore']),
      archetype: _normalizeArchetype(
        (json['archetype'] ?? 'The Mirror').toString(),
      ),
      reflection: (json['reflection'] ??
              'Tu experiencia es válida y merece ser escuchada.')
          .toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sentiment': sentiment,
      'sentimentScore': sentimentScore,
      'archetype': archetype,
      'reflection': reflection,
    };
  }

  /// Convierte distintos formatos posibles a double seguro [0.0 - 1.0]
  static double _parseScore(dynamic value) {
    if (value == null) return 0.5;

    if (value is num) {
      final v = value.toDouble();
      return v.clamp(0.0, 1.0);
    }

    final parsed = double.tryParse(value.toString());
    if (parsed == null) return 0.5;

    return parsed.clamp(0.0, 1.0);
  }

  /// Normaliza arquetipos para evitar inconsistencias del modelo
  static String _normalizeArchetype(String raw) {
    final normalized = raw.trim().toLowerCase();

    if (normalized.contains('mask')) return 'The Mask';
    if (normalized.contains('moon')) return 'The Moon';
    if (normalized.contains('shadow')) return 'The Shadow';
    if (normalized.contains('mirror')) return 'The Mirror';

    return 'The Mirror';
  }

  AnalysisResult copyWith({
    String? sentiment,
    double? sentimentScore,
    String? archetype,
    String? reflection,
  }) {
    return AnalysisResult(
      sentiment: sentiment ?? this.sentiment,
      sentimentScore: sentimentScore ?? this.sentimentScore,
      archetype: archetype ?? this.archetype,
      reflection: reflection ?? this.reflection,
    );
  }

  @override
  String toString() {
    return 'AnalysisResult(sentiment: $sentiment, score: $sentimentScore, archetype: $archetype)';
  }
}