import 'package:supabase_flutter/supabase_flutter.dart';

class AlmaQuote {
  final String texto;
  final String autor;
  final String contextoAlma;
  final bool disparadorNotificacion;

  AlmaQuote({
    required this.texto,
    required this.autor,
    required this.contextoAlma,
    required this.disparadorNotificacion,
  });
}

class QuotesEngine {
  final String arquetipo;
  final List<String> nodosDolor;

  QuotesEngine({
    required this.arquetipo,
    required this.nodosDolor,
  });

  final _client = Supabase.instance.client;

  // =========================
  // FETCH BASE DATA
  // =========================
  Future<List<Map<String, dynamic>>> _fetchQuotes() async {
    final response = await _client.from('quotes').select();

    return List<Map<String, dynamic>>.from(response);
  }

  // =========================
  // DAILY QUOTES (UI FEED)
  // =========================
  Future<List<AlmaQuote>> getDailyQuotes() async {
    final List<AlmaQuote> result = [];

    final tags = [
      arquetipo.toLowerCase(),
      ...nodosDolor.map((e) => e.toLowerCase()),
    ];

    final quotes = await _fetchQuotes();

    final filtered = quotes.where((q) {
      final List rawTags = q['tags'] ?? [];

      return rawTags.any((t) {
        return tags.contains(t.toString().toLowerCase());
      });
    }).toList();

    filtered.shuffle();

    if (filtered.isNotEmpty) {
      result.add(_mapQuote(filtered.first));
    } else {
      final fallback = quotes.where((q) {
        final List rawTags = q['tags'] ?? [];
        return rawTags.contains('reflexión');
      }).toList();

      if (fallback.isNotEmpty) {
        fallback.shuffle();
        result.add(_mapQuote(fallback.first));
      }
    }

    return result;
  }

  // =========================
  // NOTIFICATION QUOTE
  // =========================
  Future<AlmaQuote?> getNotificationQuote() async {
    final quotes = await _fetchQuotes();

    final notis = quotes.where((q) {
      return q['is_notification'] == true;
    }).toList();

    if (notis.isEmpty) return null;

    notis.shuffle();

    return _mapQuote(notis.first);
  }

  // =========================
  // MAPPER (DB → DOMAIN)
  // =========================
  AlmaQuote _mapQuote(Map<String, dynamic> q) {
    final tags = List<String>.from(q['tags'] ?? []);

    return AlmaQuote(
      texto: (q['text'] ?? '').toString(),
      autor: (q['author'] ?? 'Anónimo').toString(),
      contextoAlma: _contextoAlma(tags),
      disparadorNotificacion: q['is_notification'] ?? false,
    );
  }

  // =========================
  // CONTEXT ENGINE
  // =========================
  String _contextoAlma(List<String> tags) {
    if (tags.contains('mask')) {
      return 'Para equilibrar tu necesidad de control.';
    }
    if (tags.contains('moon')) {
      return 'Para confiar en el proceso y abrazar la incertidumbre.';
    }
    if (tags.contains('ansiedad')) {
      return 'Para invitarte a soltar el futuro y volver al presente.';
    }
    if (tags.contains('sombra')) {
      return 'Para abrazar tu vulnerabilidad.';
    }
    if (tags.contains('cambio')) {
      return 'Para acompañarte en tu proceso de transformación.';
    }
    if (tags.contains('reflexión')) {
      return 'Para inspirar tu pausa consciente.';
    }

    return 'Para tu momento presente.';
  }
}