import 'package:alma_diary/core/logging/log_service.dart';

/// MockProvider
/// Implementación simulada de proveedor de IA.
/// Se usa para:
/// - desarrollo offline
/// - testing
/// - fallback seguro cuando fallan otros providers
class MockProvider {
  /// Simula un análisis IA determinista/simple
  Future<Map<String, dynamic>> analyze(String input) async {
    LogService.instance.warning(
      'mock.provider.used',
      context: {
        'reason': 'fallback_or_testing',
        'input_length': input.length,
      },
    );

    final lower = input.toLowerCase();

    // Clasificación muy básica de sentimiento
    final sentiment = _detectSentiment(lower);

    // Score simple asociado al sentimiento
    final score = _sentimentScore(sentiment);

    // Arquetipo heurístico (placeholder)
    final archetype = _detectArchetype(lower);

    // Reflexión simulada (estructura consistente)
    final reflection = _buildReflection(sentiment);

    final result = {
      "sentiment": sentiment,
      "sentimentScore": score,
      "archetype": archetype,
      "reflection": reflection,
    };

    LogService.instance.info(
      'mock.provider.result',
      context: result,
    );

    return result;
  }

  /// Heurística simple de sentimiento
  String _detectSentiment(String text) {
    if (_containsAny(text, ['feliz', 'bien', 'contento', 'genial'])) {
      return 'positive';
    }
    if (_containsAny(text, ['triste', 'mal', 'frustrado', 'ansioso'])) {
      return 'negative';
    }
    return 'neutral';
  }

  /// Asigna score numérico al sentimiento
  double _sentimentScore(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return 0.8;
      case 'negative':
        return 0.2;
      default:
        return 0.5;
    }
  }

  /// Selección básica de arquetipo
  String _detectArchetype(String text) {
    if (text.contains('confund')) return 'The Moon';
    if (text.contains('miedo') || text.contains('ansiedad')) return 'The Shadow';
    if (text.contains('aparien') || text.contains('pretend')) return 'The Mask';
    return 'The Mirror';
  }

  /// Genera reflexión consistente (placeholder UX-safe)
  String _buildReflection(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return 'Parece que hay algo que está fluyendo bien dentro de ti. Observa qué lo está haciendo posible.';
      case 'negative':
        return 'Hay una carga emocional presente. Tal vez vale la pena detenerse un momento y escuchar qué necesita ser visto.';
      default:
        return 'Tu experiencia es válida. Quizás explorarla con más calma te dé mayor claridad.';
    }
  }

  /// Helper para detectar palabras clave
  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }
}