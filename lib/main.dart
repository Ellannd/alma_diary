import 'dart:async';
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
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.init(Environment.dev);

  await LogService.instance.init();

  ErrorHandlers.init();

  await dotenv.load(fileName: ".env");

  await bootstrapServices();

  LogContext.instance.newSession();

  runZonedGuarded(() {
    runApp(
      ProviderScope(
        child: const MyApp(),
      ),
    );
  }, ErrorHandlers.handleError);
}

