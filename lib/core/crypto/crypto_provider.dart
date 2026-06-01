
import 'package:alma_diary/features/journal/data/journal_service.dart';
import 'package:alma_diary/services/fcm_listener_service.dart';
import 'package:alma_diary/state/profile/profile_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'local_key_service.dart';
import 'encryption_service.dart';
import 'secure_storage_service.dart';

export 'local_key_service.dart'
    show LocalKeyResult, LocalKeySuccess, LocalKeyFailure;
export 'encryption_service.dart'
    show
        EncryptionService,
        EncryptResult,
        EncryptSuccess,
        EncryptFailure,
        DecryptResult,
        DecryptSuccess,
        DecryptFailure,
        CipherBundle;
export 'secure_storage_service.dart'
    show
        SecureStorageService,
        StorageReadResult,
        StorageReadSuccess,
        StorageReadMiss,
        StorageReadFailure;

// ──────────────────────────────────────────────
// PROVIDERS
// ──────────────────────────────────────────────

final secureStorageServiceProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(),
  name: 'secureStorageServiceProvider',
);

final localKeyServiceProvider = Provider<LocalKeyService>(
  (ref) => LocalKeyService(
    storage: ref.watch(secureStorageServiceProvider),
  ),
  name: 'localKeyServiceProvider',
);

final encryptionServiceProvider = Provider<EncryptionService>(
  (ref) => EncryptionService(),
  name: 'encryptionServiceProvider',
);

// keepAlive porque la sesión cripto debe vivir toda la app
final cryptoSessionProvider = FutureProvider<CryptoSession>((ref) async {
  ref.keepAlive();
  ref.watch(authChangesProvider); // se invalida con cada cambio de auth

  final session = CryptoSession(
    localKey: ref.read(localKeyServiceProvider),
    encryption: ref.read(encryptionServiceProvider),
    storage: ref.read(secureStorageServiceProvider),
  );

  final user = Supabase.instance.client.auth.currentUser;
  if (user != null) {
    session.storage.setUserId(user.id);
    final ok = await session.initializeSession();
    
    if (ok) {
      JournalService.instance.setCryptoSession(session);
      await FcmService.instance.registerDevice(user.id);
    }
  }

  return session;
});

// ──────────────────────────────────────────────
// CryptoSession
// ──────────────────────────────────────────────

class CryptoSession {
  const CryptoSession({
    required this.localKey,
    required this.encryption,
    required this.storage,
  });

  final LocalKeyService localKey;
  final EncryptionService encryption;
  final SecureStorageService storage;

  /// Obtiene o crea la key local para este usuario.
  /// Orden: Keychain → recovery desde backend → generación nueva.
  Future<bool> initializeSession() async {
    final result = await localKey.getOrCreateKey();
    return result is LocalKeySuccess;
  }

  Future<EncryptResult> encryptText(String plaintext) async {
    final keyResult = await storage.loadKey();

    if (keyResult is StorageReadMiss) {
      return const EncryptFailure(
        'No active crypto session — call initializeSession() after login.',
      );
    }
    if (keyResult is StorageReadFailure) {
      return EncryptFailure(
        'Could not load key from secure storage.',
        cause: (keyResult).cause,
      );
    }

    final key = (keyResult as StorageReadSuccess).derivedKeyBase64;
    return encryption.encrypt(plaintext, key);
  }

  Future<DecryptResult> decryptText(String serializedBundle) async {
    final keyResult = await storage.loadKey();

    if (keyResult is StorageReadMiss) {
      return const DecryptFailure(
        'No active crypto session — re-authenticate to decrypt.',
      );
    }
    if (keyResult is StorageReadFailure) {
      return DecryptFailure(
        'Could not load key from secure storage.',
        cause: (keyResult).cause,
      );
    }

    final key = (keyResult as StorageReadSuccess).derivedKeyBase64;
    return encryption.decryptSerialized(serializedBundle, key);
  }

  Future<void> clearSession() => storage.clearKey();
}