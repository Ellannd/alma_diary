import 'package:shared_preferences/shared_preferences.dart';
import 'package:alma_diary/services/supabase_service.dart';
import '../../../data/aes_encryption.dart';
import 'dart:math';

class TrajectoryStats {
  final double conscienciaDeSi;
  final double agenciaPersonal;
  final double rumiacion;
  final double integracionSombra;
  final double valentia; // Nueva métrica
  final Map<String, double> arquetipos;
  final List<String> conceptos;
  final List<String> hitos;
  final String narrativa;

  TrajectoryStats({
    required this.conscienciaDeSi,
    required this.agenciaPersonal,
    required this.rumiacion,
    required this.integracionSombra,
    required this.valentia,
    required this.arquetipos,
    required this.conceptos,
    required this.hitos,
    required this.narrativa,
  });
}

// Persistencia local simple para métrica de valentía
Future<void> incrementarValentia({int cantidad = 1}) async {
  final prefs = await SharedPreferences.getInstance();
  final actual = prefs.getInt('valentia') ?? 0;
  await prefs.setInt('valentia', actual + cantidad);
}

Future<int> obtenerValentia() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('valentia') ?? 0;
}

Future<TrajectoryStats> generar_estadisticas_trayectoria(
  String passphrase,
) async {
  final client = SupabaseService.instance.client;
  final userId = client.auth.currentUser?.id;
  if (userId == null) {
    return TrajectoryStats(
      conscienciaDeSi: 0,
      agenciaPersonal: 0,
      rumiacion: 0,
      integracionSombra: 0,
      valentia: 0,
      arquetipos: {'The Mask': 0, 'The Mirror': 0, 'The Moon': 0},
      conceptos: [],
      hitos: [],
      narrativa: 'No hay datos de usuario.',
    );
  }
  final entries = await client
      .from('journal_entries')
      .select()
      .eq('user_id', userId)
      .order('created_at', ascending: false);
  final valentia = await obtenerValentia();
  if (entries.isEmpty) {
    return TrajectoryStats(
      conscienciaDeSi: 0,
      agenciaPersonal: 0,
      rumiacion: 0,
      integracionSombra: 0,
      valentia: valentia.toDouble(),
      arquetipos: {'The Mask': 0, 'The Mirror': 0, 'The Moon': 0},
      conceptos: [],
      hitos: [],
      narrativa: 'Aún no hay suficientes datos para mostrar tu trayectoria.',
    );
  }
  final last10 = entries.take(10).toList();
  final textos = last10
      .map(
        (e) =>
            AESEncryption.decryptText(e['content_encrypted'] ?? '', passphrase),
      )
      .toList();

  // --- Métricas ---
  double conscienciaDeSi = 0,
      agenciaPersonal = 0,
      rumiacion = 0,
      integracionSombra = 0;
  final arquetipoScores = {'The Mask': 0.0, 'The Mirror': 0.0, 'The Moon': 0.0};
  final conceptos = <String>{};
  final hitos = <String>[];

  // Para hitos: guardar métricas previas
  double? prevRumiacion, prevAgencia, prevSombra;
  for (int i = 0; i < textos.length; i++) {
    final t = textos[i];
    // Consciencia de sí: uso de emociones propias
    conscienciaDeSi += _countMatches(t, [
      'siento',
      'me doy cuenta',
      'emocion',
      'reconozco',
      'percibo',
    ]);
    // Agencia personal: verbos activos
    agenciaPersonal += _countMatches(t, [
      'hice',
      'decidí',
      'accioné',
      'cambié',
      'asumí',
    ]);
    // Rumiación: palabras repetitivas negativas
    rumiacion += _countMatches(t, [
      'siempre',
      'nunca',
      'no puedo',
      'imposible',
      'fracaso',
    ]);
    // Integración sombra: honestidad sobre lo difícil
    integracionSombra += _countMatches(t, [
      'miedo',
      'vergüenza',
      'culpa',
      'sombra',
      'herida',
    ]);
    // Conceptos (simulado)
    if (t.contains('padre')) conceptos.add('Relación con el padre');
    if (t.contains('futuro')) conceptos.add('Ansiedad por el futuro');
    if (t.contains('paz')) conceptos.add('Paz matutina');
    // Arquetipos
    arquetipoScores['The Mask'] =
        arquetipoScores['The Mask']! +
        _countMatches(t, [
          'deber',
          'tengo que',
          'correcto',
          'norma',
          'protocolo',
        ]);
    arquetipoScores['The Mirror'] =
        arquetipoScores['The Mirror']! +
        _countMatches(t, ['yo', 'me', 'mi', 'logré', 'proyecté']);
    arquetipoScores['The Moon'] =
        arquetipoScores['The Moon']! +
        _countMatches(t, [
          'sueño',
          'miedo',
          'noche',
          'inconsciente',
          'intuición',
        ]);

    // Detección de hitos (cambio significativo)
    if (i > 0) {
      final currRumi = _countMatches(t, [
        'siempre',
        'nunca',
        'no puedo',
        'imposible',
        'fracaso',
      ]);
      final currAgencia = _countMatches(t, [
        'hice',
        'decidí',
        'accioné',
        'cambié',
        'asumí',
      ]);
      final currSombra = _countMatches(t, [
        'miedo',
        'vergüenza',
        'culpa',
        'sombra',
        'herida',
      ]);
      if (prevRumiacion != null &&
          prevRumiacion > 0 &&
          currRumi < prevRumiacion * 0.7) {
        hitos.add(
          'Hito alcanzado: Has reducido la rumiación en más de un 30%. ¡Felicidades por transformar tu diálogo interno!',
        );
      }
      if (prevAgencia != null && currAgencia > prevAgencia * 1.3) {
        hitos.add(
          'Hito alcanzado: Has incrementado tu agencia personal en más de un 30%. ¡Estás tomando acción consciente!',
        );
      }
      if (prevSombra != null && currSombra > prevSombra * 1.3) {
        hitos.add(
          'Hito alcanzado: Has integrado aspectos de tu sombra con honestidad. ¡Gran avance en autoconocimiento!',
        );
      }
      prevRumiacion = currRumi;
      prevAgencia = currAgencia;
      prevSombra = currSombra;
    } else {
      prevRumiacion = _countMatches(t, [
        'siempre',
        'nunca',
        'no puedo',
        'imposible',
        'fracaso',
      ]);
      prevAgencia = _countMatches(t, [
        'hice',
        'decidí',
        'accioné',
        'cambié',
        'asumí',
      ]);
      prevSombra = _countMatches(t, [
        'miedo',
        'vergüenza',
        'culpa',
        'sombra',
        'herida',
      ]);
    }
  }
  final n = textos.length.toDouble();
  // Normalizar a 0-100
  double norm(double v) => min(100, (v / n) * 20);
  final stats = TrajectoryStats(
    conscienciaDeSi: norm(conscienciaDeSi),
    agenciaPersonal: norm(agenciaPersonal),
    rumiacion: norm(rumiacion),
    integracionSombra: norm(integracionSombra),
    valentia: valentia.toDouble(),
    arquetipos: {
      for (final k in arquetipoScores.keys)
        k: min(100, (arquetipoScores[k]! / n) * 25),
    },
    conceptos: conceptos.toList(),
    hitos: hitos,
    narrativa: _generarNarrativa(
      stats: [conscienciaDeSi, agenciaPersonal, rumiacion, integracionSombra],
      arquetipos: arquetipoScores,
      conceptos: conceptos,
    ),
  );
  return stats;
}

double _countMatches(String text, List<String> patterns) {
  double count = 0;
  for (final p in patterns) {
    count += RegExp(p, caseSensitive: false).allMatches(text).length;
  }
  return count;
}

String _generarNarrativa({
  required List<double> stats,
  required Map<String, double> arquetipos,
  required Set<String> conceptos,
}) {
  // Simulación de narrativa basada en métricas
  final frases = <String>[];
  if (stats[2] < 2) {
    frases.add(
      'Has reducido el uso de lenguaje absolutista. Esto indica mayor flexibilidad mental.',
    );
  }
  if (stats[1] > 2) {
    frases.add(
      'Tu agencia personal ha subido: usas más verbos de acción que pasivos.',
    );
  }
  if (arquetipos['The Moon']! > 2) {
    frases.add(
      'Estás explorando tu mundo interior y sueños con mayor profundidad.',
    );
  }
  if (conceptos.isNotEmpty) {
    frases.add('Conceptos clave en tu proceso: ${conceptos.join(", ")}.');
  }
  if (frases.isEmpty) return 'Sigue escribiendo para descubrir más sobre ti.';
  return frases.join(' ');
}
