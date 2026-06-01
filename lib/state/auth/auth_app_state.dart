

/// =========================
/// STATE
/// =========================
class AuthAppState {
  final bool isLoading;
  final bool needsEmailConfirmation;
  final String? error;

  const AuthAppState({
    this.isLoading = false,
    this.needsEmailConfirmation = false,
    this.error,
  });

  AuthAppState copyWith({
    bool? isLoading,
    bool? needsEmailConfirmation,
    String? error,
  }) => AuthAppState(
    isLoading: isLoading ?? this.isLoading,
    needsEmailConfirmation: needsEmailConfirmation ?? this.needsEmailConfirmation,
    error: error,
  );

  factory AuthAppState.initial() => const AuthAppState();
}