import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import "package:alma_diary/core/logging/log_service.dart";
import "package:alma_diary/core/logging/log_context.dart";

class EncryptionService {
  static EncryptionService? _instance;
  static EncryptionService get instance => _instance ??= EncryptionService._();

  EncryptionService._();

  enc.Key? _key;
  enc.Encrypter? _encrypter;

  static const String _defaultKey = 'AlmaDiary2024SecureKey32Bytes!';

  static String getKeyForUser(String? userId) {
    if (userId == null || userId.isEmpty) {
      return _defaultKey;
    }
    return 'Alma_${userId.substring(0, 8)}_Secure_${DateTime.now().year}';
  }

  void initialize({String? userId}) {
    final keyStr = userId != null ? getKeyForUser(userId) : _defaultKey;
    _key = enc.Key.fromUtf8(keyStr.padRight(32).substring(0, 32));
    _encrypter = enc.Encrypter(enc.AES(_key!, mode: enc.AESMode.cbc));
    LogContext.instance.setUser(userId ?? 'default');
    LogService.instance.info('EncryptionService inicializado');
  }

  String encrypt(String plainText) {
    if (_encrypter == null) {
      initialize();
    }
    
    final iv = enc.IV.fromSecureRandom(16);
    final encrypted = _encrypter!.encrypt(plainText, iv: iv);
    
    final combined = iv.bytes + encrypted.bytes;
    return base64Encode(combined);
  }

  String decrypt(String encryptedText) {
    if (_encrypter == null) {
      initialize();
    }

    try {
      final raw = base64Decode(encryptedText);
      final iv = enc.IV(Uint8List.fromList(raw.sublist(0, 16)));
      final cipherText = raw.sublist(16);
      final decrypted = _encrypter!.decrypt(enc.Encrypted(Uint8List.fromList(cipherText)), iv: iv);
      return decrypted;
    } catch (e, stackTrace) {
      LogService.instance.error(
      'Error al descifrar en EncryptionService',
      error: e,
      stackTrace: stackTrace,
    );
      return '[Contenido cifrado]';
    }
  }

  Map<String, dynamic> encryptEntry(Map<String, dynamic> entry) {
    final encryptedEntry = Map<String, dynamic>.from(entry);
    
    if (encryptedEntry.containsKey('texto_encriptado') && encryptedEntry['texto_encriptado'] is String) {
      encryptedEntry['texto_encriptado'] = encrypt(encryptedEntry['texto_encriptado']);
    }
    
    if (encryptedEntry.containsKey('content') && encryptedEntry['content'] is String) {
      encryptedEntry['content'] = encrypt(encryptedEntry['content']);
    }
    
    if (encryptedEntry.containsKey('analysis') && encryptedEntry['analysis'] is String) {
      encryptedEntry['analysis'] = encrypt(encryptedEntry['analysis']);
    }
    
    return encryptedEntry;
  }

  Map<String, dynamic> decryptEntry(Map<String, dynamic> entry) {
    final decryptedEntry = Map<String, dynamic>.from(entry);
    
    if (decryptedEntry.containsKey('texto_encriptado') && decryptedEntry['texto_encriptado'] is String) {
      decryptedEntry['texto_plain'] = decrypt(decryptedEntry['texto_encriptado']);
    }
    
    if (decryptedEntry.containsKey('content') && decryptedEntry['content'] is String) {
      decryptedEntry['content'] = decrypt(decryptedEntry['content']);
    }
    
    if (decryptedEntry.containsKey('analysis') && decryptedEntry['analysis'] is String) {
      decryptedEntry['analysis'] = decrypt(decryptedEntry['analysis']);
    }
    
    return decryptedEntry;
  }

  static String encryptText(String plainText, String passphrase) {
    final keyBytes = enc.Key.fromUtf8(passphrase.padRight(32).substring(0, 32));
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(keyBytes, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    final result = iv.bytes + encrypted.bytes;
    return base64Encode(result);
  }

  static String decryptText(String encryptedText, String passphrase) {
    final raw = base64Decode(encryptedText);
    final iv = enc.IV(Uint8List.fromList(raw.sublist(0, 16)));
    final cipherText = raw.sublist(16);
    final keyBytes = enc.Key.fromUtf8(passphrase.padRight(32).substring(0, 32));
    final encrypter = enc.Encrypter(enc.AES(keyBytes, mode: enc.AESMode.cbc));
    return encrypter.decrypt(enc.Encrypted(Uint8List.fromList(cipherText)), iv: iv);
  }
}