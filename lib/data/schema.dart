import 'dart:convert';
import 'package:uuid/uuid.dart';

class JournalEntry {
  final String id;
  final DateTime fecha;
  final String textoEncriptado;
  final List<String> emociones;
  final List<String> patrones;
  final bool crisisDetectada;
  final List<String> recursosSugeridos;
  final List<String> preguntasCatalizadoras;
  final RitualCierre? ritualCierre;
  final String? sentimiento;
  final double? sentimientoScore;
  final String? arquetipo;
  final String? reflexion;

  JournalEntry({
    String? id,
    required this.fecha,
    required this.textoEncriptado,
    this.emociones = const [],
    this.patrones = const [],
    this.crisisDetectada = false,
    this.recursosSugeridos = const [],
    this.preguntasCatalizadoras = const [],
    this.ritualCierre,
    this.sentimiento,
    this.sentimientoScore,
    this.arquetipo,
    this.reflexion,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'fecha': fecha.toIso8601String(),
        'texto_encriptado': textoEncriptado,
        'emociones': emociones,
        'patrones': patrones,
        'crisis_detectada': crisisDetectada,
        'recursos_sugeridos': recursosSugeridos,
        'preguntas_catalizadoras': preguntasCatalizadoras,
        'ritual_cierre': ritualCierre?.toJson(),
        'sentimiento': sentimiento,
        'sentimiento_score': sentimientoScore,
        'arquetipo': arquetipo,
        'reflexion': reflexion,
      };

  static JournalEntry fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'],
        fecha: DateTime.parse(json['fecha']),
        textoEncriptado: json['texto_encriptado'],
        emociones: List<String>.from(json['emociones'] ?? []),
        patrones: List<String>.from(json['patrones'] ?? []),
        crisisDetectada: json['crisis_detectada'] ?? false,
        recursosSugeridos: List<String>.from(json['recursos_sugeridos'] ?? []),
        preguntasCatalizadoras: List<String>.from(json['preguntas_catalizadoras'] ?? []),
        ritualCierre: json['ritual_cierre'] != null ? RitualCierre.fromJson(json['ritual_cierre']) : null,
        sentimiento: json['sentimiento'],
        sentimientoScore: json['sentimiento_score'] != null ? (json['sentimiento_score'] as num).toDouble() : null,
        arquetipo: json['arquetipo'],
        reflexion: json['reflexion'],
      );
}

class RitualCierre {
  final String tipo;
  final String contenido;

  RitualCierre({required this.tipo, required this.contenido});

  Map<String, dynamic> toJson() => {
        'tipo': tipo,
        'contenido': contenido,
      };

  static RitualCierre fromJson(Map<String, dynamic> json) => RitualCierre(
        tipo: json['tipo'],
        contenido: json['contenido'],
      );
}

// Utilidades para encriptar/desencriptar (placeholder, implementar con lib real)
String encriptarTexto(String texto, String clave) {
  // TODO: Implementar encriptación real
  return base64Encode(utf8.encode(texto));
}

String desencriptarTexto(String textoEncriptado, String clave) {
  // TODO: Implementar desencriptación real
  return utf8.decode(base64Decode(textoEncriptado));
}

