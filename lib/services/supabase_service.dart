import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';
import '../core/logging/log_service.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance =>
      _instance ??= SupabaseService._();

  SupabaseService._();

  late final SupabaseClient _client;
  SupabaseClient get client => _client;

  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // =========================
  // INIT
  // =========================
  static Future<void> init() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );

    _instance = SupabaseService._();
    _instance!._client = Supabase.instance.client;

    LogService.instance.info('supabase.initialized');
  }

  // =========================
  // AUTH STATE STREAM
  // =========================
  Stream<User?> get authStateChanges =>
      _client.auth.onAuthStateChange.map(
        (event) => event.session?.user,
      );
}