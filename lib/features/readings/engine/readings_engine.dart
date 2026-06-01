import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import "package:alma_diary/services/supabase_service.dart";
import 'package:shared_preferences/shared_preferences.dart';

class PersonalizedReading {
  final String title;
  final String content;
  final String author;
  final String quote;

  const PersonalizedReading({
    required this.title,
    required this.content,
    required this.author,
    required this.quote,
  });

  factory PersonalizedReading.fromJson(Map<String, dynamic> json) {
    return PersonalizedReading(
      title: json['title'] ?? 'Sin título',
      content: json['content'] ?? '',
      author: json['author'] ?? 'Anónimo',
      quote: json['quote'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'content': content,
      'author': author,
      'quote': quote,
      'date_saved': DateTime.now().toIso8601String(),
    };
  }
}

class ReadingRecommendation {
  final String idLectura;
  final String titulo;
  final String autor;
  final String porqueLeerla;
  final String tag;
  final String nivelDeConsciencia;
  final String fragmento;

  ReadingRecommendation({
    required this.idLectura,
    required this.titulo,
    required this.autor,
    required this.porqueLeerla,
    required this.tag,
    required this.nivelDeConsciencia,
    required this.fragmento,
  });
}

class ReadingsEngine {


Future<List<ReadingRecommendation>> getRecommendations() async {
  final response = await SupabaseService.instance.client
      .from('readings')
      .select()
      .order('created_at', ascending: false);

  final data = List<Map<String, dynamic>>.from(response);

return data.map((item) {
  final tagsRaw = item['tags'];

  final List<String> tags = tagsRaw is List
      ? List<String>.from(tagsRaw)
      : (tagsRaw is String
          ? tagsRaw.split(',').map((e) => e.trim()).toList()
          : []);

  return ReadingRecommendation(
    idLectura: (item['id'] ?? '').toString(),
    titulo: (item['title'] ?? 'Sin título').toString(),
    autor: (item['author'] ?? 'Desconocido').toString(),

    // 🔥 FIX: usa primer tag real
    tag: tags.isNotEmpty ? tags.first : 'general',

    // 🔥 FIX: no existe en DB → fallback inteligente
    porqueLeerla: 'Lectura basada en psicología aplicada y análisis emocional.',

    // 🔥 FIX: tampoco existe → derivado de categoría si quieres
    nivelDeConsciencia: (item['category'] ?? 'básico').toString(),

    // 🔥 FIX CRÍTICO: aquí estaba tu bug de "texto vacío"
    fragmento: (item['content'] ?? '').toString(),
  );
}).toList();
}


  Future<Map<String, String>> generatePersonalizedReading() async {
    final userId = SupabaseService.instance.client.auth.currentUser?.id;

  if (userId == null) {
    throw Exception('User not authenticated');
  }

  final entries = await SupabaseService.instance.client
      .from('journal_entries')
      .select()
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .limit(10);

  if (entries.isEmpty) {
    throw Exception(
      'No journal entries found. Please add some diary entries first.',
    );
  }

  final last3 = entries.take(3).toList();

  final archetype =
      (last3.first['arquetipo'] ?? 'The Mirror').toString();

  final List<String> keywords = [];

  for (final entry in last3) {
    final rawTags = entry['etiquetas_ia'];

    if (rawTags is String && rawTags.isNotEmpty) {
      keywords.addAll(
        rawTags
            .split(',')
            .map((k) => k.trim().toLowerCase())
            .where((k) => k.isNotEmpty),
      );
    }
  }

  final uniqueKeywords = keywords.toSet().take(10).toList();

  final prompt = """
Genera una lectura de biblioterapia personalizada.

Arquetipo: $archetype

Keywords: ${uniqueKeywords.join(', ')}

Extensión: 250-400 palabras.

Estructura: Título, contenido reflexivo y cita final.

Salida JSON:
{"title":"...","content":"...","author":"...","quote":"..."}
""";

  final prefs = await SharedPreferences.getInstance();

  final apiKey = prefs.getString('gemini_api_key') ??
      'TU_API_KEY_DEFAULT';

  final model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: apiKey,
  );

  final response = await model.generateContent([
    Content.text(prompt),
  ]);

  final rawText = response.text?.trim() ?? '{}';
  final cleanedText = _cleanResponse(rawText);

  final decoded = jsonDecode(cleanedText) as Map<String, dynamic>;

  return {
    'title': decoded['title'] ?? 'Lectura Personalizada',
    'content': decoded['content'] ?? '',
    'author': decoded['author'] ?? 'Anónimo',
    'quote': decoded['quote'] ?? '',
  };
}

  String _cleanResponse(String response) {
    return response
        .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^```\s*', multiLine: true), '')
        .replaceAll(RegExp(r'\s*```$', multiLine: true), '')
        .trim();
  }
}
