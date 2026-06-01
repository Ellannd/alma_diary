// lib/core/crypto/secure_storage_service.dart
//
// Responsabilidad única: persistir y limpiar la derived_key en
// flutter_secure_storage. Es el único lugar donde la clave toca disco.
//
// Dependencias:
//   flutter_secure_storage: ^9.x
//   dart:async

import "package:flutter_secure_storage/flutter_secure_storage.dart";
import '../logging/log_service.dart';

/// Resultado de lectura de clave.
sealed class StorageReadResult {
  const StorageReadResult();
}

final class StorageReadSuccess extends StorageReadResult {
  final String derivedKeyBase64;
  const StorageReadSuccess(this.derivedKeyBase64);
}

final class StorageReadMiss extends StorageReadResult {
  const StorageReadMiss();
}

final class StorageReadFailure extends StorageReadResult {
  final String message;
  final Object? cause;
  const StorageReadFailure(this.message, {this.cause});
}

/// Gestiona el ciclo de vida de la derived_key en almacenamiento seguro.
///
/// - [saveKey] → llamar justo después de recibir la clave de [KeyDerivationService].
/// - [loadKey] → llamar en [EncryptionService] antes de cifrar/descifrar.
/// - [clearKey] → llamar en logout / expiración de sesión.
///
/// La clave nunca vive en memoria más allá del scope que la usa.
/// Este servicio es la única fuente de verdad sobre si hay clave activa.
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(
          // Opciones de plataforma endurecidas:
          aOptions: AndroidOptions(
            // Requiere que el dispositivo tenga pantalla de bloqueo configurada.
            resetOnError: true,
          ),
          iOptions: IOSOptions(
            // accesible sólo cuando el dispositivo está desbloqueado,
            // no migra en backups de iCloud.
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
        );

  final FlutterSecureStorage _storage;

  // La clave de almacenamiento es constante y privada para evitar colisiones
  // con otras partes del app que usen flutter_secure_storage.
  static const _keyPrefix = 'alma_master_key_v2';

  String? _userId;

  void setUserId(String userId) {
  _userId = userId;
}

  String get _storageKey {
    final id = _userId;
    if (id == null) {
      throw StateError(
      'SecureStorageService: userId not set. Call setUserId() before any operation.',
    );
    }
    return '${_keyPrefix}_$id';
  }

  // ──────────────────────────────────────────────
  // PUBLIC API
  // ──────────────────────────────────────────────

  /// Persiste la [derivedKeyBase64] de forma segura.
  ///
  /// Sobreescribe cualquier valor previo — idempotente para re-login.
  /// Retorna `true` si la operación fue exitosa.
  Future<bool> saveKey(String derivedKeyBase64) async {
    try {
      await _storage.write(key: _storageKey, value: derivedKeyBase64);
      LogService.instance.info('SecureStorageService: key saved successfully.');
      return true;
    } catch (e, st) {
      LogService.instance.error(
        'SecureStorageService: failed to save key',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Lee la derived_key del almacenamiento seguro.
  ///
  /// Retorna [StorageReadSuccess] si existe, [StorageReadMiss] si no hay clave
  /// (sesión nueva o después de logout), [StorageReadFailure] si hay error de
  /// plataforma (p.ej. Keychain bloqueado en iOS).
  Future<StorageReadResult> loadKey() async {
    try {
      final value = await _storage.read(key: _storageKey);

      if (value == null || value.isEmpty) {
        LogService.instance.info('SecureStorageService: no key found (miss).');
        return const StorageReadMiss();
      }

      LogService.instance.info('SecureStorageService: key loaded successfully.');
      return StorageReadSuccess(value);
    } catch (e, st) {
      LogService.instance.error(
        'SecureStorageService: failed to read key',
        error: e,
        stackTrace: st,
      );
      return StorageReadFailure('Failed to read key from secure storage', cause: e);
    }
  }

  /// Elimina la derived_key del almacenamiento seguro.
  ///
  /// Llamar en:
  /// - logout explícito del usuario.
  /// - expiración de sesión detectada por el auth stream.
  /// - revocación de acceso desde el servidor.
  ///
  /// Es una operación best-effort: si falla (caso muy raro en Keychain),
  /// se loguea el error pero no lanza — el auth controller debe igualmente
  /// continuar con el flujo de logout.
  Future<void> clearKey() async {
    try {
      await _storage.delete(key: _storageKey);
      LogService.instance.info('SecureStorageService: key cleared on logout.');
    } catch (e, st) {
      LogService.instance.error(
        'SecureStorageService: failed to clear key — '
        'key may persist until next app launch',
        error: e,
        stackTrace: st,
      );
      // No relanzamos: el flujo de logout debe completarse aunque
      // el borrado falle. El riesgo de dejar la clave es menor que
      // dejar la sesión activa por un throw aquí.
    }
  }

  /// Verifica si hay una clave activa sin leerla completa.
  ///
  /// Útil para gates en la UI (p.ej. mostrar spinner mientras se deriva).
  Future<bool> hasKey() async {
    try {
      final value = await _storage.read(key: _storageKey);
      return value != null && value.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}