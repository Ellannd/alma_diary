/// Define los arquetipos usados en el sistema de análisis.
///
/// Este enum centraliza:
/// - Valores válidos (evita strings mágicos)
/// - Normalización desde IA (modelos pueden variar output)
/// - Extensibilidad futura (nuevos arquetipos, metadata, UI mapping)
///
/// Mantener sincronizado con:
/// - prompts (lo que el modelo devuelve)
/// - UI (iconos, colores, copy)
enum Archetype {
  mirror,
  mask,
  moon,
  shadow;

  String get displayName => label;

  /// Nombre canónico (para serialización / logs / debugging)
  String get key {
    switch (this) {
      case Archetype.mirror:
        return 'mirror';
      case Archetype.mask:
        return 'mask';
      case Archetype.moon:
        return 'moon';
      case Archetype.shadow:
        return 'shadow';
    }
  }

  /// Label listo para UI (consistente con diseño actual)
  String get label {
    switch (this) {
      case Archetype.mirror:
        return 'The Mirror';
      case Archetype.mask:
        return 'The Mask';
      case Archetype.moon:
        return 'The Moon';
      case Archetype.shadow:
        return 'The Shadow';
    }
  }

  /// Descripción corta (útil para tooltips / onboarding / future UX)
  String get description {
    switch (this) {
      case Archetype.mirror:
        return 'Refleja tu estado interno con claridad.';
      case Archetype.mask:
        return 'Explora lo que ocultas o proyectas.';
      case Archetype.moon:
        return 'Navega la incertidumbre y lo no resuelto.';
      case Archetype.shadow:
        return 'Conecta con emociones profundas o evitadas.';
    }
  }

  /// Parseo robusto desde texto (IA puede devolver formatos inconsistentes)
  static Archetype fromString(String? raw) {
    if (raw == null) return Archetype.mirror;

    final normalized = raw.toLowerCase();

    if (normalized.contains('mask')) return Archetype.mask;
    if (normalized.contains('moon')) return Archetype.moon;
    if (normalized.contains('shadow')) return Archetype.shadow;
    if (normalized.contains('mirror')) return Archetype.mirror;

    // fallback seguro
    return Archetype.mirror;
  }

  /// Serialización simple (para storage / analytics)
  static Archetype fromKey(String? key) {
    switch (key) {
      case 'mask':
        return Archetype.mask;
      case 'moon':
        return Archetype.moon;
      case 'shadow':
        return Archetype.shadow;
      case 'mirror':
      default:
        return Archetype.mirror;
    }
  }
}