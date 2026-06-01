// lib/core/crypto/local_key_service.dart
//
// Responsabilidad: generar, persistir y recuperar la master key local.
//
// Flujo:
//   - Primer login → genera 32 bytes aleatorios → wrap en backend → guarda en Keychain
//   - Logins siguientes → lee del Keychain directamente
//   - Recovery (reinstalación) → llama unwrap-key → guarda en Keychain

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'secure_storage_service.dart';
import '../logging/log_service.dart';

sealed class LocalKeyResult { const LocalKeyResult(); }

final class LocalKeySuccess extends LocalKeyResult {
  final String keyBase64;
  const LocalKeySuccess(this.keyBase64);
}

final class LocalKeyFailure extends LocalKeyResult {
  final String message;
  final Object? cause;
  const LocalKeyFailure(this.message, {this.cause});
}

class LocalKeyService {
  LocalKeyService({
    required SecureStorageService storage,
    SupabaseClient? client,
  })  : _storage = storage,
        _client = client ?? Supabase.instance.client;

  final SecureStorageService _storage;
  final SupabaseClient _client;

  static const _wrapFunction   = 'wrap-key';
  static const _unwrapFunction = 'unwrap-key';

  // ──────────────────────────────────────────────
  // PUBLIC API
  // ──────────────────────────────────────────────

  /// Retorna la key activa para este usuario.
  ///
  /// Orden de resolución:
  ///   1. Keychain local (caso más común, sin red)
  ///   2. Recovery desde backend (reinstalación / nuevo dispositivo)
  ///   3. Generación nueva + wrap en backend (primer login)
  Future<LocalKeyResult> getOrCreateKey() async {
    // 1. Keychain hit — camino feliz
    final cached = await _storage.loadKey();
    if (cached is StorageReadSuccess) {
      LogService.instance.info('LocalKeyService: key loaded from keychain.');
      return LocalKeySuccess(cached.derivedKeyBase64);
    }

    // 2. Intentar recovery — puede que el usuario reinstalò la app
    final recovered = await _recoverKey();
    if (recovered is LocalKeySuccess) return recovered;

    // 3. Primera vez — generar y wrap
    return await _generateAndWrapKey();
  }

  // ──────────────────────────────────────────────
  // PRIVATE
  // ──────────────────────────────────────────────

  /// Intenta recuperar la key desde el backend (unwrap-key).
  /// Retorna [LocalKeySuccess] si el usuario ya tenía una key wrapeada,
  /// [LocalKeyFailure] si no existe (primer login real).
  Future<LocalKeyResult> _recoverKey() async {
    try {
      final response = await _client.functions.invoke(
        _unwrapFunction,
        method: HttpMethod.post,
        body: <String, dynamic>{},
      );

      if (response.status == 404) {
        // No hay wrapped key — es un primer login real, no recovery
        LogService.instance.info('LocalKeyService: no wrapped key found — first login.');
        return const LocalKeyFailure('No wrapped key — first login.');
      }

      if (response.status != 200) {
        LogService.instance.warning(
          'LocalKeyService: unwrap-key returned ${response.status}',
        );
        return LocalKeyFailure('unwrap-key error (HTTP ${response.status})');
      }

      final data = response.data;
      if (data is! Map<String, dynamic> || data['key_local'] is! String) {
        return const LocalKeyFailure('Malformed response from unwrap-key.');
      }

      final keyBase64 = data['key_local'] as String;

      // Validar que sean 32 bytes
      if (base64.decode(keyBase64).length != 32) {
        return const LocalKeyFailure('Recovered key is not 32 bytes.');
      }

      // Persistir localmente para no volver a llamar al backend
      final saved = await _storage.saveKey(keyBase64);
      if (!saved) return const LocalKeyFailure('Failed to persist recovered key.');

      LogService.instance.info('LocalKeyService: key recovered from backend.');
      return LocalKeySuccess(keyBase64);

    } on FunctionException catch (e) {
      LogService.instance.error(
        'LocalKeyService: FunctionException on unwrap-key',
        error: e,
      );
      return LocalKeyFailure('Failed to reach unwrap-key.', cause: e);
    } catch (e, st) {
      LogService.instance.error(
        'LocalKeyService: unexpected error on unwrap-key',
        error: e,
        stackTrace: st,
      );
      return LocalKeyFailure('Unexpected error during recovery.', cause: e);
    }
  }

  /// Genera una key nueva, la wrappea en el backend y la persiste localmente.
  Future<LocalKeyResult> _generateAndWrapKey() async {
    // Generar 32 bytes seguros
    final keyBytes = _generateSecureKey();
    final keyBase64 = base64.encode(keyBytes);

    // Wrap en backend — si falla, no persistimos localmente
    // para evitar inconsistencia entre Keychain y DB
    final wrapOk = await _wrapKey(keyBase64);
    if (!wrapOk) {
      return const LocalKeyFailure('Failed to wrap key in backend.');
    }

    // Persistir localmente solo si el wrap fue exitoso
    final saved = await _storage.saveKey(keyBase64);
    if (!saved) {
      return const LocalKeyFailure('Key wrapped but failed to save locally.');
    }

    LogService.instance.info('LocalKeyService: new key generated and wrapped.');
    return LocalKeySuccess(keyBase64);
  }

  /// Llama wrap-key con la keyLocal para custodia en backend.
  Future<bool> _wrapKey(String keyBase64) async {
    try {
      final response = await _client.functions.invoke(
        _wrapFunction,
        method: HttpMethod.post,
        body: {'key_local': keyBase64},
      );

      if (response.status != 200) {
        LogService.instance.warning(
          'LocalKeyService: wrap-key returned ${response.status}',
        );
        return false;
      }

      return true;
    } on FunctionException catch (e) {
      LogService.instance.error(
        'LocalKeyService: FunctionException on wrap-key',
        error: e,
      );
      return false;
    } catch (e, st) {
      LogService.instance.error(
        'LocalKeyService: unexpected error on wrap-key',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  Uint8List _generateSecureKey() {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(32, (_) => random.nextInt(256)),
    );
  }
}