import 'package:flutter/foundation.dart';

import 'core/logging/log_service.dart';
import 'core/logging/crash/crash_reporter.dart';

import 'services/supabase_service.dart';
import 'services/storage_service.dart';
import 'services/encryption_service.dart';

import 'firebase_bootstrap.dart';

Future<void> bootstrapServices() async {
  LogService.instance.info(
    'Iniciando Bootstrap services...',
  );

  /// =========================
  /// FIREBASE
  /// =========================

  await _safeInit(
    name: 'Firebase',
    task: initFirebase,
  );

  /// =========================
  /// ENCRYPTION
  /// =========================

  await _safeInit(
    name: 'EncryptionService',
    task: () async {
      EncryptionService.instance.initialize();
    },
  );

  /// =========================
  /// CRASH REPORTER
  /// =========================

  await _safeInit(
    name: 'CrashReporter',
    task: CrashReporter.instance.init,
  );

  /// =========================
  /// SUPABASE
  /// =========================

  await _safeInit(
    name: 'Supabase',
    task: SupabaseService.init,
  );

  /// =========================
  /// STORAGE
  /// =========================

  if (!kIsWeb) {
    try {
      await StorageService.instance.init();

      LogService.instance.info(
        'StorageService inicializado (Mobile)',
      );
    } catch (e, st) {
      LogService.instance.warning(
        'StorageService no disponible',
        error: e,
        stackTrace: st,
      );
    }
  } else {
    LogService.instance.info(
      'Web: Storage delegado a Supabase/LocalStorage',
    );
  }
}

/// =========================
/// SAFE INIT
/// =========================

Future<void> _safeInit({
  required String name,
  required Future<void> Function() task,
}) async {
  try {
    await task();

    LogService.instance.info(
      '$name inicializado',
    );
  } catch (e, st) {
    LogService.instance.error(
      'Error inicializando $name',
      error: e,
      stackTrace: st,
    );

    rethrow;
  }
}