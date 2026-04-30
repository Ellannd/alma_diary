import 'package:alma_diary/services/supabase_service.dart';
import '../../data/aes_encryption.dart';

class ReflectionCard {
  final String titulo;
  final String hallazgo;
  final String perspectivaHumanista;
  final String accionConsciente;
  final String arquetipo;

  ReflectionCard({
    required this.titulo,
    required this.hallazgo,
    required this.perspectivaHumanista,
    required this.accionConsciente,
    required this.arquetipo,
  });

  Map<String, dynamic> toJson() => {
    'titulo': titulo,
    'hallazgo': hallazgo,
    'perspectiva_humanista': perspectivaHumanista,
    'accion_consciente': accionConsciente,
    'arquetipo': arquetipo,
  };
}

class ReflectionsEngine {
  final String passphrase;
  ReflectionsEngine(this.passphrase);

  Future<List<ReflectionCard>> generateReflections() async {
    final client = SupabaseService.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return _cachedOrDefault();
    final entries = await client
        .from('journal_entries')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    if (entries.isEmpty) return _cachedOrDefault();
    final lastEntries = entries.take(7).toList();
    final texts = lastEntries
        .map(
          (e) => AESEncryption.decryptText(
            e['content_encrypted'] ?? '',
            passphrase,
          ),
        )
        .toList();
    // --- Análisis transversal ---
    final allText = texts.join(' ').toLowerCase();
    final keywords = [
      'siempre',
      'nunca',
      'tengo que',
      'debería',
      'cansancio',
      'descanso',
    ];
    final keywordCounts = {
      for (var k in keywords) k: RegExp(k).allMatches(allText).length,
    };

    // --- Arquetipo ---
    final arquetipo = _detectarArquetipo(texts);
    // --- Reflexiones ---
    final List<ReflectionCard> cards = [
      ReflectionCard(
        titulo: 'El peso de la armadura',
        hallazgo:
            "Tus últimas ${texts.length} entradas muestran que estás priorizando el 'hacer' sobre el 'ser'. La palabra 'cansancio' aparece ${keywordCounts['cansancio']} veces, pero 'descanso' solo ${keywordCounts['descanso']}.",
        perspectivaHumanista:
            'Como decía Frankl, el esfuerzo sin sentido es lo que agota el alma. Tu cansancio no es falta de energía, es falta de pausa consciente.',
        accionConsciente:
            "¿Qué pasaría si hoy te permites ser un estudiante que simplemente observa, en lugar de uno que solo resuelve?",
        arquetipo: arquetipo,
      ),
      ReflectionCard(
        titulo: 'Conexiones Temporales',
        hallazgo:
            'El lunes te sentías diferente a hoy. Nota cómo ha cambiado tu lenguaje emocional.',
        perspectivaHumanista:
            'La resiliencia se construye reconociendo los matices de cada día.',
        accionConsciente: 'Hoy, intenta no usar la palabra "debería".',
        arquetipo: arquetipo,
      ),
      ReflectionCard(
        titulo: 'Sabiduría de tu Sombra',
        hallazgo:
            'He notado que cuando hablas de ciertas personas o situaciones, tu lenguaje se vuelve evasivo.',
        perspectivaHumanista:
            'El autoconocimiento surge cuando abrazamos tanto la luz como la sombra.',
        accionConsciente:
            'Escribe una frase donde reconozcas una emoción difícil sin juzgarla.',
        arquetipo: arquetipo,
      ),
    ];
    // Guardar en caché local (simulado)
    _cacheReflections(cards);
    return cards;
  }


  String _detectarArquetipo(List<String> textos) {
    final joined = textos.join(' ').toLowerCase();
    if (RegExp(r'yo|logré|mi meta|me siento').allMatches(joined).length > 5) {
      return 'The Mirror';
    }
    if (RegExp(r'sueño|miedo|inconsciente|noche').allMatches(joined).length >
        3) {
      return 'The Moon';
    }
    if (RegExp(
          r'describir|análisis|técnico|proceso',
        ).allMatches(joined).length >
        3) {
      return 'The Mask';
    }
    return 'The Mirror';
  }

  // --- Caché de reflexiones (simulado con memoria estática) ---
  static List<ReflectionCard>? _lastCache;
  void _cacheReflections(List<ReflectionCard> cards) {
    _lastCache = cards;
  }

  List<ReflectionCard> _cachedOrDefault() {
    return _lastCache ??
        [
          ReflectionCard(
            titulo: 'Sin datos',
            hallazgo: 'Aún no hay suficientes entradas para reflexionar.',
            perspectivaHumanista: 'Cada inicio es un acto de valentía.',
            accionConsciente:
                'Escribe tu primera entrada para comenzar el viaje.',
            arquetipo: 'The Mirror',
          ),
        ];
  }
}
