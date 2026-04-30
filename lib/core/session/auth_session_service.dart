import 'package:supabase_flutter/supabase_flutter.dart';

class AuthSessionService {
  final SupabaseClient _client;

  AuthSessionService(this._client);

  /// Usuario actual autenticado
  User? get currentUser => _client.auth.currentUser;

  /// ID del usuario
  String? get userId => _client.auth.currentUser?.id;

  /// Email del usuario
  String? get email => _client.auth.currentUser?.email;

  /// Saber si hay sesión activa
  bool get isLoggedIn => _client.auth.currentUser != null;

  /// Stream de cambios de auth (login/logout)
  Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;
}