import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'features/dashboard/alma_theme.dart';
import 'features/auth/auth_gate.dart';
import 'features/journal/alma_journal.dart';
import 'features/profile/profile_page.dart';
import 'core/logging/log_service.dart';
import 'services/supabase_service.dart';
import 'services/storage_service.dart';
import 'services/encryption_service.dart';
import 'core/theme/theme_controller.dart';
import 'core/logging/error_handlers.dart';
import 'core/config/app_environment.dart';
import 'core/navigation/app_navigator_observer.dart';
import 'core/logging/log_context.dart';
import 'core/logging/crash/crash_reporter.dart';
import "package:flutter_dotenv/flutter_dotenv.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.init(Environment.dev);

  await LogService.instance.init();

  ErrorHandlers.init();

  await dotenv.load(fileName: ".env");

  await _bootstrapServices();

  LogContext.instance.newSession();

  ErrorHandlers.runAppGuarded(const MyApp());
}

Future<void> initFirebase() async {
  try{
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,);
    LogService.instance.info("Inicializando Firebase...");
  }
  catch(e){
    LogService.instance.error("Error al inicializar Firebase: $e");
  }
}

Future<void> _bootstrapServices() async {
  LogService.instance.info('Iniciando Bootstrap services...');

  try{
    await initFirebase();
      LogService.instance.info('Firebase inicializado');
  } catch (e) {
    LogService.instance.error('Error inicializando Firebase', error: e);}


  EncryptionService.instance.initialize();
  
  LogService.instance.info('EncryptionService inicializado');
  
  await CrashReporter.instance.init();
  try {
    await SupabaseService.init();
    LogService.instance.info('Supabase inicializado');
  } catch (e) {
    LogService.instance.error('Error inicializando Supabase', error: e);
  }

  if (!kIsWeb) {
    try {
      await StorageService.instance.init();
      LogService.instance.info('StorageService inicializado (Mobile)');
    } catch (e) {
      LogService.instance.warning('StorageService no disponible: $e');
    }
  } else {
    LogService.instance.info(
      'Web: Storage delegado a Supabase/LocalStorage',
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.notifier,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'Alma - Diario Consciente',
          debugShowCheckedModeBanner: false,

          // TEMA DINÁMICO
          theme: isDark ? AlmaTheme.dark : AlmaTheme.light,

          initialRoute: '/',
          routes: {
            '/': (context) => const AuthGate(),
            '/journal': (context) => const AlmaJournal(),
            '/profile': (context) => const ProfilePage(),
          },

          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              builder: (_) => const AuthGate(),
            );
          },
          navigatorObservers: [
            AppNavigatorObserver(),
          ],
        );
      },
    );
  }
}