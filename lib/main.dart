import 'dart:async';
import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:alma_diary/features/profile/data/profile_repository.dart';
import 'package:alma_diary/state/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/logging/log_service.dart';
import 'core/logging/error_handlers.dart';
import 'core/config/app_environment.dart';
import 'core/logging/log_context.dart';
import "package:flutter_dotenv/flutter_dotenv.dart";
import "bootstrap.dart";
import "app.dart";

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await dotenv.load(fileName: '.env');
    AppConfig.init(Environment.dev);
    await LogService.instance.init();
    ErrorHandlers.init();
    await bootstrapServices();
    LogContext.instance.newSession();

  // Errores de Flutter framework
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Errores de Dart async fuera del widget tree
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

    runApp(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(
            ProfileRepository(),
          ),
        ],
        child: const MyApp(),
      ),
    );
  }, ErrorHandlers.handleError);
}
