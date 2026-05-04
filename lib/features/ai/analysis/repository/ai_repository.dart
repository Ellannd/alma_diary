import '../domain/analysis_result.dart';

/// AIRepository
///
/// Contrato abstracto del sistema de IA.
///
/// Objetivo:
/// - desacoplar dominio de implementación (Gemini / HF / Mock)
/// - permitir swap de providers sin romper arquitectura
/// - testabilidad total (mock fácil)
///
abstract class AIRepository {
  /// Analiza un texto y devuelve el resultado estructurado.
  Future<AnalysisResult> analyze(String input);
}