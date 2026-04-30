import 'package:flutter/foundation.dart'show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alma_diary/services/supabase_service.dart';
import 'package:alma_diary/core/logging/log_service.dart';

class AuthRepository {
  final SupabaseService _supabase = SupabaseService.instance;
  SupabaseClient get _client => _supabase.client;

   // =========================
  // GOOGLE
  // =========================
  Future<void> signInWithGoogle() async {
    try {
      LogService.instance.info('auth.google_start');

      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? 'http://localhost:5000' : null,
      );
    } catch (e, st) {
      LogService.instance.error(
        'auth.google_failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  // =========================
  // EMAIL / PASSWORD
  // =========================
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      LogService.instance.info('auth.email_signin_success');
    } catch (e, st) {
      LogService.instance.error(
        'auth.email_signin_failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
      );

      LogService.instance.info('auth.signup_success');
    } catch (e, st) {
      LogService.instance.error(
        'auth.signup_failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  // =========================
  // RESET PASSWORD
  // =========================
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);

      LogService.instance.info('auth.reset_sent');
    } catch (e, st) {
      LogService.instance.error(
        'auth.reset_failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

   // =========================
  // SIGN OUT
  // =========================
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();

      LogService.instance.info('auth.signout');
    } catch (e, st) {
      LogService.instance.error(
        'auth.signout_failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  // =========================
  // STATE
  // =========================
  User? get currentUser => _supabase.currentUser;

  bool get isAuthenticated => currentUser != null;

  Stream<User?> get authState =>
      _client.auth.onAuthStateChange.map((e) => e.session?.user);
}