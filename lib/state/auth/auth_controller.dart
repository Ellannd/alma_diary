import "dart:async";

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import "package:alma_diary/state/auth/auth_app_state.dart";
import "package:alma_diary/features/auth/data/auth_repository.dart";
import "package:alma_diary/core/logging/log_service.dart";

/// =========================
/// PROVIDERS
/// =========================
final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthAppState>(
  AuthController.new,
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// =========================
/// CONTROLLER
/// =========================
class AuthController extends AsyncNotifier<AuthAppState> {
  late final SupabaseClient _supabase;
  late final AuthRepository _repo;
  StreamSubscription<AuthState>? _authSub;

  @override
  Future<AuthAppState> build() async {
    
    ref.onDispose(() => _authSub?.cancel());

    _supabase = ref.read(supabaseClientProvider);
    
    _repo = ref.read(authRepositoryProvider);
    _listenAuthChanges();

    final user = _supabase.auth.currentSession?.user;

    return AuthAppState(
      user: user,
      isAuthenticated: user != null,
      isLoading: false,
      error: null,
    );
  }

  // =========================
  // AUTH LISTENER
  // =========================
  void _listenAuthChanges() {
    _authSub = _supabase.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;

      // Solo actualiza si el notifier sigue vivo
      if (state case AsyncData(:final value)) {
        state = AsyncData(
          value.copyWith(
            user: user,
            clearUser: user == null,
            isAuthenticated: user != null,
          ),
        );
      }
    });
  }

  // =========================
  // HELPERS INTERNOS
  // =========================

  /// Lee el estado actual de forma segura, lanza si no está listo.
  AuthAppState get _state => state.requireValue;

  /// Actualiza el estado de forma segura.
  void _setState(AuthAppState next) => state = AsyncData(next);

  // =========================
  // SIGN IN — EMAIL
  // =========================
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setState(_state.copyWith(isLoading: true, error: null));

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      _setState(_state.copyWith(
        user: user,
        isAuthenticated: user != null,
        isLoading: false,
      ));

      LogService.instance.info(
        'auth.signin_email_success',
        context: {'user_id': user?.id},
      );
    } on AuthException catch (e, st) {
      LogService.instance.error(
        'auth.signin_email_failed',
        error: e,
        stackTrace: st,
      );

      _setState(_state.copyWith(
        isLoading: false,
        error: e.message,
      ));
    } catch (e, st) {
      LogService.instance.error(
        'auth.signin_email_unexpected',
        error: e,
        stackTrace: st,
      );

      _setState(_state.copyWith(
        isLoading: false,
        error: 'Error inesperado al iniciar sesión',
      ));
    }
  }

  // =========================
  // SIGN UP — EMAIL
  // =========================
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    _setState(_state.copyWith(isLoading: true, error: null));

    try {
      final result = await _repo.signUpWithEmail(email, password);

      if (result == SignUpResult.needsEmailConfirmation) {
        _setState(_state.copyWith(
          isLoading: false,
          needsEmailConfirmation: true, // nuevo campo en AuthAppState
        ));
        return;
      }

      _setState(_state.copyWith(isLoading: false));
    } catch (e, st) {
      _setState(_state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // =========================
  // SIGN IN — GOOGLE
  // =========================
  Future<void> signInWithGoogle() async {
    _setState(_state.copyWith(isLoading: true, error: null));

    try {
      await _repo.signInWithGoogle();
      // onAuthStateChange maneja el user automáticamente
      // solo bajamos el loading aquí por si el flujo OAuth
      // no dispara el listener de inmediato
      _setState(_state.copyWith(isLoading: false));

      LogService.instance.info('auth.signin_google_success');
    } on AuthException catch (e, st) {
      LogService.instance.error(
        'auth.signin_google_failed',
        error: e,
        stackTrace: st,
      );

      _setState(_state.copyWith(
        isLoading: false,
        error: e.message,
      ));
    } catch (e, st) {
      LogService.instance.error(
        'auth.signin_google_unexpected',
        error: e,
        stackTrace: st,
      );

      _setState(_state.copyWith(
        isLoading: false,
        error: 'Error inesperado con Google',
      ));
    }
  }

  // =========================
  // SIGN OUT
  // =========================
  Future<void> signOut() async {
    _setState(_state.copyWith(isLoading: true, error: null));

    try {
      await _supabase.auth.signOut();

      _setState(AuthAppState.initial());

      LogService.instance.info('auth.signout_success');
    } on AuthException catch (e, st) {
      LogService.instance.error(
        'auth.signout_failed',
        error: e,
        stackTrace: st,
      );

      _setState(_state.copyWith(
        isLoading: false,
        error: e.message,
      ));
    } catch (e, st) {
      LogService.instance.error(
        'auth.signout_unexpected',
        error: e,
        stackTrace: st,
      );

      _setState(_state.copyWith(
        isLoading: false,
        error: 'Error inesperado al cerrar sesión',
      ));
    }
  }

  // =========================
  // HELPERS PÚBLICOS
  // =========================
  void clearError() {
    if (state case AsyncData(:final value)) {
      state = AsyncData(value.copyWith(error: null));
    }
  }

  User? get currentUser => state.asData?.value.user;
  bool get isAuthenticated => state.asData?.value.isAuthenticated ?? false;
}