// lib/core/crypto/encryption_service.dart
//
// Responsabilidad única: cifrar y descifrar texto con AES-256-GCM
// usando la derived_key recibida como base64.
//
// Dependencias:
//   pointycastle: ^3.x          (AES-GCM implementation)
//   dart:typed_data
//   dart:math
//   dart:convert

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

/// Resultado de cifrado. Encapsula ciphertext + IV en un único string
/// serializable para persistir en Supabase sin columnas extra.
///
/// Formato en wire: base64(iv) + "." + base64(ciphertext+tag)
/// Separador "." es seguro porque base64 estándar no lo usa.
final class CipherBundle {
  final String ivBase64;
  final String cipherBase64; // ciphertext || GCM auth tag (16 bytes al final)

  const CipherBundle({required this.ivBase64, required this.cipherBase64});

  /// Serializa a un único string para guardar en la columna `content_v2`.
  String serialize() => '$ivBase64.$cipherBase64';

  /// Parsea desde el string serializado. Lanza [FormatException] si malformado.
  factory CipherBundle.deserialize(String raw) {
    final parts = raw.split('.');
    if (parts.length != 2) {
      throw const FormatException('CipherBundle: expected format iv.cipher');
    }
    return CipherBundle(ivBase64: parts[0], cipherBase64: parts[1]);
  }
}

sealed class EncryptResult {
  const EncryptResult();
}

final class EncryptSuccess extends EncryptResult {
  final CipherBundle bundle;
  const EncryptSuccess(this.bundle);
}

final class EncryptFailure extends EncryptResult {
  final String message;
  final Object? cause;
  const EncryptFailure(this.message, {this.cause});
}

sealed class DecryptResult {
  const DecryptResult();
}

final class DecryptSuccess extends DecryptResult {
  final String plaintext;
  const DecryptSuccess(this.plaintext);
}

final class DecryptFailure extends DecryptResult {
  final String message;
  final Object? cause;
  const DecryptFailure(this.message, {this.cause});
}

/// Servicio de cifrado simétrico AES-256-GCM.
///
/// Uso típico:
/// 
/// final svc = EncryptionService();
/// final enc = svc.encrypt('entrada del diario', derivedKeyBase64);
/// if (enc is EncryptSuccess) {
///   final serialized = enc.bundle.serialize(); // guarda esto en Supabase
/// }
/// 
///
/// El IV se genera fresco en cada llamada a [encrypt] — nunca se reutiliza.
class EncryptionService {
  // AES-256-GCM: key = 32 bytes, IV = 12 bytes (96 bits, estándar NIST).
  static const _keyBytes = 32;
  static const _ivBytes = 12;
  // GCM tag size en bytes (128 bits = máximo seguridad).
  static const _tagBytes = 16;

  final Random _random;

  EncryptionService({Random? random})
      : _random = random ?? Random.secure();

  // ──────────────────────────────────────────────
  // PUBLIC API
  // ──────────────────────────────────────────────

  /// Cifra [plaintext] con la [derivedKeyBase64] derivada por [KeyDerivationService].
  ///
  /// Genera un IV aleatorio de 12 bytes en cada llamada.
  /// Retorna [EncryptSuccess] con el [CipherBundle] listo para serializar.
  EncryptResult encrypt(String plaintext, String derivedKeyBase64) {
    try {
      final key = _decodeKey(derivedKeyBase64);
      final iv = _randomIv();
      final input = utf8.encode(plaintext);

      final cipher = _buildCipher(forEncryption: true, key: key, iv: iv);
      final output = cipher.process(input);
      // PointyCastle GCM appends the 16-byte tag at the end of output.

      return EncryptSuccess(
        CipherBundle(
          ivBase64: base64.encode(iv),
          cipherBase64: base64.encode(output),
        ),
      );
    } catch (e) {
      return EncryptFailure('Encryption failed', cause: e);
    }
  }

  /// Descifra un [CipherBundle] previamente serializado con [encrypt].
  ///
  /// Valida el GCM auth tag internamente — si el ciphertext fue manipulado,
  /// PointyCastle lanza [InvalidCipherTextException] y retornamos [DecryptFailure].
  DecryptResult decrypt(CipherBundle bundle, String derivedKeyBase64) {
    try {
      final key = _decodeKey(derivedKeyBase64);
      final iv = base64.decode(bundle.ivBase64);
      final cipherWithTag = base64.decode(bundle.cipherBase64);

      final cipher = _buildCipher(forEncryption: false, key: key, iv: iv);
      final plainBytes = cipher.process(cipherWithTag);

      return DecryptSuccess(utf8.decode(plainBytes));
    } on InvalidCipherTextException catch (e) {
      // Auth tag mismatch — datos corruptos o clave incorrecta.
      return DecryptFailure(
        'GCM authentication failed — data may be corrupt or key is wrong.',
        cause: e,
      );
    } catch (e) {
      return DecryptFailure('Decryption failed', cause: e);
    }
  }

  /// Conveniencia: descifra desde el string serializado directamente.
  DecryptResult decryptSerialized(String serialized, String derivedKeyBase64) {
    try {
      final bundle = CipherBundle.deserialize(serialized);
      return decrypt(bundle, derivedKeyBase64);
    } on FormatException catch (e) {
      return DecryptFailure('Invalid cipher bundle format', cause: e);
    }
  }

  // ──────────────────────────────────────────────
  // PRIVATE HELPERS
  // ──────────────────────────────────────────────

  /// Decodifica y valida la clave base64. Lanza si no es exactamente 32 bytes.
  Uint8List _decodeKey(String keyBase64) {
    // Normalizar base64url → base64 estándar
    final normalized = keyBase64
        .replaceAll('-', '+')
        .replaceAll('_', '/')
        .replaceAll(RegExp(r'\s'), '');

    final bytes = base64.decode(normalized);
    if (bytes.length != _keyBytes) {
      throw ArgumentError(
        'Expected $_keyBytes-byte key, got ${bytes.length} bytes '
        '(raw input length: ${keyBase64.length}). '
        'Ensure the Edge Function returns a 256-bit derived key.',
      );
    }
    return Uint8List.fromList(bytes); // fromList en lugar de cast
}

  /// Genera un IV aleatorio seguro de 12 bytes.
  Uint8List _randomIv() {
    final iv = Uint8List(_ivBytes);
    for (var i = 0; i < _ivBytes; i++) {
      iv[i] = _random.nextInt(256);
    }
    return iv;
  }

  /// Construye y inicializa el cipher AES-256-GCM con PointyCastle.
  GCMBlockCipher _buildCipher({
    required bool forEncryption,
    required Uint8List key,
    required Uint8List iv,
  }) {
    final cipher = GCMBlockCipher(AESEngine());
    cipher.init(
      forEncryption,
      AEADParameters(
        KeyParameter(key),
        _tagBytes * 8, // tag length en bits
        iv,
        Uint8List(0), // AAD vacío — añade contexto si necesitas binding a userId
      ),
    );
    return cipher;
  }
}