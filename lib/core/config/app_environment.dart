import 'package:alma_diary/core/logging/log_entry.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment {
  dev,
  staging,
  prod,
}

class AppConfig {
  final Environment environment;

  // FLAGS
  final bool enableLogs;
  final bool enableCrashReporting;
  final bool enableAnalytics;

  // LOG LEVEL
  final LogLevel minLogLevel;

  // AUTH
  /// URL de callback OAuth para web. Leída desde .env en tiempo de init.
  final String oauthWebRedirectUrl;

  /// URL scheme de callback OAuth para móvil. Constante por build flavor.
  final String oauthMobileRedirectUrl;

  const AppConfig._({
    required this.environment,
    required this.enableLogs,
    required this.enableCrashReporting,
    required this.enableAnalytics,
    required this.minLogLevel,
    required this.oauthWebRedirectUrl,
    required this.oauthMobileRedirectUrl,
  });

  // -------------------------
  // FACTORIES
  // -------------------------

  factory AppConfig.dev() {
    return AppConfig._(
      environment: Environment.dev,
      enableLogs: true,
      enableCrashReporting: false,
      enableAnalytics: false,
      minLogLevel: LogLevel.debug,
      // Dev: leída desde .env → OAUTH_WEB_REDIRECT_URL=http://localhost:5000
      oauthWebRedirectUrl: dotenv.env['OAUTH_WEB_REDIRECT_URL'] ?? '',
      oauthMobileRedirectUrl: dotenv.env['OAUTH_MOBILE_REDIRECT_URL']
          ?? 'io.supabase.almadiary://login-callback',
    );
  }

  factory AppConfig.staging() {
    return AppConfig._(
      environment: Environment.staging,
      enableLogs: true,
      enableCrashReporting: true,
      enableAnalytics: false,
      minLogLevel: LogLevel.info,
      oauthWebRedirectUrl: dotenv.env['OAUTH_WEB_REDIRECT_URL'] ?? '',
      oauthMobileRedirectUrl: dotenv.env['OAUTH_MOBILE_REDIRECT_URL']
          ?? 'io.supabase.almadiary://login-callback',
    );
  }

  factory AppConfig.prod() {
    return AppConfig._(
      environment: Environment.prod,
      enableLogs: true,
      enableCrashReporting: true,
      enableAnalytics: true,
      minLogLevel: LogLevel.warning,
      oauthWebRedirectUrl: dotenv.env['OAUTH_WEB_REDIRECT_URL'] ?? '',
      oauthMobileRedirectUrl: dotenv.env['OAUTH_MOBILE_REDIRECT_URL']
          ?? 'io.supabase.almadiary://login-callback',
    );
  }

  // -------------------------
  // SINGLETON GLOBAL
  // -------------------------

  static AppConfig? _instance;

  static AppConfig get instance {
    final inst = _instance;
    if (inst == null) {
      throw StateError(
        'AppConfig not initialized. Call AppConfig.init() first.\n'
        'Ensure dotenv.load() completes before AppConfig.init().',
      );
    }
    return inst;
  }

  /// Inicializa el singleton. dotenv.load() debe haberse completado antes.
  ///
  /// Orden correcto en main.dart:
  /// 
  /// await dotenv.load(fileName: '.env');   // 1 — siempre primero
  /// AppConfig.init(Environment.dev);       // 2 — lee dotenv
  /// LogService.instance.init(...);         // 3 — puede usar AppConfig
  /// await Supabase.initialize(...);        // 4
  /// 
  static void init(Environment env) {
    assert(
      dotenv.isEveryDefined(['OAUTH_WEB_REDIRECT_URL']),
      'OAUTH_WEB_REDIRECT_URL missing in .env — '
      'check that dotenv.load() ran before AppConfig.init()',
    );

    switch (env) {
      case Environment.dev:
        _instance = AppConfig.dev();
      case Environment.staging:
        _instance = AppConfig.staging();
      case Environment.prod:
        _instance = AppConfig.prod();
    }
  }

  // -------------------------
  // HELPERS
  // -------------------------

  static bool get isDev => instance.environment == Environment.dev;
  static bool get isProd => instance.environment == Environment.prod;

  /// Redirect URL correcta según plataforma.
  /// Usar en AuthRepository — no leer kIsWeb fuera de aquí.
  static String oauthRedirectUrl({required bool isWeb}) =>
      isWeb ? instance.oauthWebRedirectUrl : instance.oauthMobileRedirectUrl;

  static String get googleServerClientId =>
    dotenv.get('GOOGLE_SERVER_CLIENT_ID');
}

