import 'package:alma_diary/services/fcm_listener_service.dart';
import 'package:flutter/foundation.dart';
import "package:google_fonts/google_fonts.dart";

import 'package:intl/date_symbol_data_local.dart';

import 'core/logging/log_service.dart';
import 'core/logging/crash/crash_reporter.dart';

import 'services/supabase_service.dart';
import 'services/storage_service.dart';

import 'firebase_bootstrap.dart';

Future<void> bootstrapServices() async {
  LogService.instance.info(
    'Iniciando Bootstrap services...',
  );

   await _initFonts();



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
  /// FIREBASE
  /// =========================

  await _safeInit(
    name: 'Firebase',
    task: initFirebase,
  );
  
    /// =========================
  /// FCM Listener
  /// =========================
  
  await _safeInit(
    name: 'FcmService',
    task: FcmService.instance.init,
  );

  /// =========================
  /// INTL (Date Formatting)
  /// =========================

  await _safeInit(
    name: "Intl Date Formatting", 
    task: () => initializeDateFormatting('es', null)
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

  Future<void> _initFonts() async {
  await GoogleFonts.pendingFonts([
    GoogleFonts.inter(),
    GoogleFonts.manrope(),
    GoogleFonts.roboto(),
  ]);
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

    return;
  }


}