import 'package:supabase_flutter/supabase_flutter.dart';


/// =========================
/// STATE
/// =========================
class AuthAppState {
  final User? user;
  final bool isLoading;
  final bool isAuthenticated;
  final bool needsEmailConfirmation;
  final String? error;

  const AuthAppState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.needsEmailConfirmation = false,
    this.error,
  });

  AuthAppState copyWith({
    User? user,
    bool? clearUser,         // flag explícito para nullear
    bool? isLoading,
    bool? isAuthenticated,
    bool? needsEmailConfirmation,
    String? error,
  }) {
    return AuthAppState(
      user: (clearUser == true) ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      needsEmailConfirmation: needsEmailConfirmation ?? this.needsEmailConfirmation,
      error: error,
    );
  }

  factory AuthAppState.initial() => const AuthAppState();
}