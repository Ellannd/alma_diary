import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// =========================
/// STATE
/// =========================
class AuthAppState {
  final User? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  const AuthAppState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  AuthAppState copyWith({
    User? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthAppState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }

  factory AuthAppState.initial() => const AuthAppState();
}

/// =========================
/// PROVIDER
/// =========================
final authControllerProvider =
    NotifierProvider<AuthController, AuthAppState>(
  AuthController.new,
);

/// =========================
/// CONTROLLER
/// =========================
class AuthController extends Notifier<AuthAppState> {
  late final SupabaseClient _supabase;

  @override
  AuthAppState build() {
    _supabase = Supabase.instance.client;

    _listenAuthChanges();

    return AuthAppState.initial();
  }

  // =========================
  // AUTH LISTENER
  // =========================
  void _listenAuthChanges() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;

      state = state.copyWith(
        user: user,
        isAuthenticated: user != null,
      );
    });
  }

  // =========================
  // LOGIN
  // =========================
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      state = state.copyWith(
        user: user,
        isAuthenticated: user != null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // =========================
  // SIGN UP
  // =========================
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      state = state.copyWith(
        user: user,
        isAuthenticated: user != null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // =========================
  // SIGN OUT
  // =========================
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await _supabase.auth.signOut();
      state = AuthAppState.initial();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // =========================
  // HELPERS
  // =========================
  void clearError() {
    state = state.copyWith(error: null);
  }

  User? get currentUser => state.user;
  bool get isLoggedIn => state.isAuthenticated;
}