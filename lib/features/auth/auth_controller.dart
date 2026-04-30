import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/features/auth/data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController {
  final AuthRepository _repo;

  AuthController(this._repo);

  // =========================
  // GOOGLE
  // =========================
  Future<void> loginWithGoogle() async {
    try {
      await _repo.signInWithGoogle();
    } catch (e, st) {
      LogService.instance.error(
        'auth.controller_google_failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  // =========================
  // EMAIL LOGIN
  // =========================
  Future<void> loginWithEmail(String email, String password) async {
    try {
      await _repo.signInWithEmail(email, password);
    } catch (e, st) {
      LogService.instance.error(
        'auth.controller_email_login_failed',
        error: e,
        stackTrace: st,
        context: {'email': email},
      );
      rethrow;
    }
  }

  // =========================
  // REGISTER
  // =========================
  Future<void> register(String email, String password) async {
    try {
      await _repo.signUpWithEmail(email, password);
    } catch (e, st) {
      LogService.instance.error(
        'auth.controller_register_failed',
        error: e,
        stackTrace: st,
        context: {'email': email},
      );
      rethrow;
    }
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    try {
      await _repo.signOut();
    } catch (e, st) {
      LogService.instance.error(
        'auth.controller_logout_failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  User? get currentUser => _repo.currentUser;
}