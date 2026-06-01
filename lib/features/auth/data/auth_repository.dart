import 'package:alma_diary/core/config/app_environment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alma_diary/services/supabase_service.dart';
import 'package:alma_diary/core/logging/log_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final SupabaseService _supabase = SupabaseService.instance;
  SupabaseClient get _client => _supabase.client;

   // =========================
  // GOOGLE
  // =========================
  Future<void> signInWithGoogle() async {
  try {
    LogService.instance.info('auth.google_start');

    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(
      serverClientId: AppConfig.googleServerClientId,
    );

    final account = await googleSignIn.authenticate();
    final auth = account.authentication;
    final idToken = auth.idToken;

    if (idToken == null) throw Exception('No idToken recibido de Google');

    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );

    LogService.instance.info('auth.google_success');
  } catch (e, st) {
    LogService.instance.error('auth.google_failed', error: e, stackTrace: st);
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

Future<SignUpResult> signUpWithEmail(
  String email,
  String password, {
  String? name, // opcional, se guarda en user.userMetadata
}) async {
  try {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: 'com.alma.diario://login-callback',
      data: name != null && name.isNotEmpty
          ? {'full_name': name} 
          : null,
    );

    LogService.instance.info('auth.signup_success');

    if (response.user != null && response.session == null) {
      return SignUpResult.needsEmailConfirmation;
    }

    return SignUpResult.success;
  } catch (e, st) {
    LogService.instance.error('auth.signup_failed', error: e, stackTrace: st);
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


enum SignUpResult { success, needsEmailConfirmation }