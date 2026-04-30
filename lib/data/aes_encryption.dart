import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;

class AESEncryption {
  static String encryptText(String plainText, String key) {
    final keyBytes = encrypt.Key.fromUtf8(key.padRight(32).substring(0, 32));
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes, mode: encrypt.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    final result = iv.bytes + encrypted.bytes;
    return base64Encode(result);
  }

  static String decryptText(String encryptedText, String key) {
    final raw = base64Decode(encryptedText);
    final iv = encrypt.IV(Uint8List.fromList(raw.sublist(0, 16)));
    final cipherText = raw.sublist(16);
    final keyBytes = encrypt.Key.fromUtf8(key.padRight(32).substring(0, 32));
    final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes, mode: encrypt.AESMode.cbc));
    final decrypted = encrypter.decrypt(encrypt.Encrypted(Uint8List.fromList(cipherText)), iv: iv);
    return decrypted;
  }
}
