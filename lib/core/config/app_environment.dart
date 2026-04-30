import 'package:alma_diary/core/logging/log_entry.dart';


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

  const AppConfig._({
    required this.environment,
    required this.enableLogs,
    required this.enableCrashReporting,
    required this.enableAnalytics,
    required this.minLogLevel,
  });

  // -------------------------
  // FACTORIES
  // -------------------------

  factory AppConfig.dev() {
    return const AppConfig._(
      environment: Environment.dev,
      enableLogs: true,
      enableCrashReporting: false,
      enableAnalytics: false,
      minLogLevel: LogLevel.debug,
    );
  }

  factory AppConfig.staging() {
    return const AppConfig._(
      environment: Environment.staging,
      enableLogs: true,
      enableCrashReporting: true,
      enableAnalytics: false,
      minLogLevel: LogLevel.info,
    );
  }

  factory AppConfig.prod() {
    return const AppConfig._(
      environment: Environment.prod,
      enableLogs: true,
      enableCrashReporting: true,
      enableAnalytics: true,
      minLogLevel: LogLevel.warning,
    );
  }

  // -------------------------
  // SINGLETON GLOBAL
  // -------------------------

  static AppConfig? _instance;

  static AppConfig get instance {
    final inst = _instance;
    if (inst == null) {
      throw Exception(
        'AppConfig not initialized. Call AppConfig.init() first.',
      );
    }
    return inst;
  }

  static void init(Environment env) {
    switch (env) {
      case Environment.dev:
        _instance = AppConfig.dev();
        break;
      case Environment.staging:
        _instance = AppConfig.staging();
        break;
      case Environment.prod:
        _instance = AppConfig.prod();
        break;
    }
  }

  // -------------------------
  // HELPERS
  // -------------------------

  static bool get isDev => instance.environment == Environment.dev;

  static bool get isProd => instance.environment == Environment.prod;
}