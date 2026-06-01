// test/crypto/crypto_service_test.dart
//
// Tests unitarios para EncryptionService y SecureStorageService.
// No requieren dispositivo — corren en dart test puro.
//
// Para correr:
//   flutter test test/crypto/crypto_service_test.dart

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Ajusta los imports al path real de tu proyecto:
import 'package:alma_diary/core/crypto/encryption_service.dart';
import 'package:alma_diary/core/crypto/secure_storage_service.dart';

@GenerateMocks([FlutterSecureStorage])
import 'crypto_service_test.mocks.dart';

// ──────────────────────────────────────────────
// HELPERS
// ──────────────────────────────────────────────

/// Genera una clave de 32 bytes aleatoria en base64 para tests.
String _testKey() {
  final bytes = Uint8List(32);
  final rng = Random.secure();
  for (var i = 0; i < 32; i++) {
    bytes[i] = rng.nextInt(256);
  }
  return base64.encode(bytes);
}

void main() {
  // ──────────────────────────────────────────────
  // EncryptionService
  // ──────────────────────────────────────────────

  group('EncryptionService', () {
    late EncryptionService svc;
    late String key;

    setUp(() {
      svc = EncryptionService();
      key = _testKey();
    });

    test('encrypt retorna EncryptSuccess con bundle no vacío', () {
      final result = svc.encrypt('hola mundo', key);
      expect(result, isA<EncryptSuccess>());
      final bundle = (result as EncryptSuccess).bundle;
      expect(bundle.ivBase64, isNotEmpty);
      expect(bundle.cipherBase64, isNotEmpty);
    });

    test('decrypt recupera el texto original', () {
      const plaintext = 'entrada del diario con ñ y emojis 🌙';
      final enc = svc.encrypt(plaintext, key) as EncryptSuccess;
      final dec = svc.decrypt(enc.bundle, key);
      expect(dec, isA<DecryptSuccess>());
      expect((dec as DecryptSuccess).plaintext, equals(plaintext));
    });

    test('roundtrip vía serialización', () {
      const plaintext = 'test serialization roundtrip';
      final enc = svc.encrypt(plaintext, key) as EncryptSuccess;
      final serialized = enc.bundle.serialize();
      final dec = svc.decryptSerialized(serialized, key);
      expect((dec as DecryptSuccess).plaintext, equals(plaintext));
    });

    test('cada encrypt genera un IV diferente', () {
      const text = 'mismo texto';
      final r1 = svc.encrypt(text, key) as EncryptSuccess;
      final r2 = svc.encrypt(text, key) as EncryptSuccess;
      // IVs distintos → ciphertexts distintos (probabilístico, prácticamente cierto)
      expect(r1.bundle.ivBase64, isNot(equals(r2.bundle.ivBase64)));
      expect(r1.bundle.cipherBase64, isNot(equals(r2.bundle.cipherBase64)));
    });

    test('decrypt con clave incorrecta retorna DecryptFailure (GCM tag mismatch)', () {
      final enc = svc.encrypt('secreto', key) as EncryptSuccess;
      final wrongKey = _testKey(); // clave diferente
      final dec = svc.decrypt(enc.bundle, wrongKey);
      expect(dec, isA<DecryptFailure>());
    });

    test('decrypt con ciphertext modificado retorna DecryptFailure', () {
      const text = 'datos intactos';
      final enc = svc.encrypt(text, key) as EncryptSuccess;
      // Corrompe el ciphertext decodificando, mutando un byte, recodificando
      final cipherBytes = base64.decode(enc.bundle.cipherBase64);
      cipherBytes[0] ^= 0xFF;
      final corruptBundle = CipherBundle(
        ivBase64: enc.bundle.ivBase64,
        cipherBase64: base64.encode(cipherBytes),
      );
      final dec = svc.decrypt(corruptBundle, key);
      expect(dec, isA<DecryptFailure>());
    });

    test('encrypt con clave de longitud incorrecta retorna EncryptFailure', () {
      final shortKey = base64.encode(Uint8List(16)); // 16 bytes, no 32
      final result = svc.encrypt('texto', shortKey);
      expect(result, isA<EncryptFailure>());
    });

    test('CipherBundle.deserialize lanza FormatException con separador faltante', () {
      expect(
        () => CipherBundle.deserialize('sinpuntoaqui'),
        throwsA(isA<FormatException>()),
      );
    });

    test('texto vacío se cifra y descifra correctamente', () {
      final enc = svc.encrypt('', key) as EncryptSuccess;
      final dec = svc.decryptSerialized(enc.bundle.serialize(), key);
      expect((dec as DecryptSuccess).plaintext, equals(''));
    });

    test('texto largo (10k chars) pasa el roundtrip', () {
      final longText = 'a' * 10000;
      final enc = svc.encrypt(longText, key) as EncryptSuccess;
      final dec = svc.decryptSerialized(enc.bundle.serialize(), key);
      expect((dec as DecryptSuccess).plaintext, equals(longText));
    });
  });

  // ──────────────────────────────────────────────
  // SecureStorageService
  // ──────────────────────────────────────────────

  group('SecureStorageService', () {
    late MockFlutterSecureStorage mockStorage;
    late SecureStorageService svc;
    const storageKey = 'alma_crypto_derived_key_v1';

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      svc = SecureStorageService(storage: mockStorage);
    });

    test('saveKey escribe en storage y retorna true', () async {
      when(mockStorage.write(key: storageKey, value: anyNamed('value')))
          .thenAnswer((_) async {});
      final result = await svc.saveKey('dGVzdGtleWJhc2U2NA==');
      expect(result, isTrue);
      verify(mockStorage.write(
        key: storageKey,
        value: 'dGVzdGtleWJhc2U2NA==',
      )).called(1);
    });

    test('loadKey retorna StorageReadSuccess cuando hay valor', () async {
      when(mockStorage.read(key: storageKey))
          .thenAnswer((_) async => 'dGVzdGtleQ==');
      final result = await svc.loadKey();
      expect(result, isA<StorageReadSuccess>());
      expect((result as StorageReadSuccess).derivedKeyBase64, 'dGVzdGtleQ==');
    });

    test('loadKey retorna StorageReadMiss cuando no hay valor', () async {
      when(mockStorage.read(key: storageKey)).thenAnswer((_) async => null);
      final result = await svc.loadKey();
      expect(result, isA<StorageReadMiss>());
    });

    test('loadKey retorna StorageReadFailure cuando storage lanza', () async {
      when(mockStorage.read(key: storageKey)).thenThrow(Exception('Keychain locked'));
      final result = await svc.loadKey();
      expect(result, isA<StorageReadFailure>());
    });

    test('clearKey llama delete en storage', () async {
      when(mockStorage.delete(key: storageKey)).thenAnswer((_) async {});
      await svc.clearKey();
      verify(mockStorage.delete(key: storageKey)).called(1);
    });

    test('clearKey no lanza aunque storage falle', () async {
      when(mockStorage.delete(key: storageKey)).thenThrow(Exception('Keychain error'));
      // No debe lanzar — logout debe completarse igualmente
      expect(() => svc.clearKey(), returnsNormally);
    });

    test('hasKey retorna true cuando hay valor', () async {
      when(mockStorage.read(key: storageKey)).thenAnswer((_) async => 'somekey');
      expect(await svc.hasKey(), isTrue);
    });

    test('hasKey retorna false cuando no hay valor', () async {
      when(mockStorage.read(key: storageKey)).thenAnswer((_) async => null);
      expect(await svc.hasKey(), isFalse);
    });

    test('saveKey retorna false si storage lanza', () async {
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenThrow(Exception('write failed'));
      final result = await svc.saveKey('somekey');
      expect(result, isFalse);
    });
  });
}