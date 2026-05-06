
import 'package:supabase_flutter/supabase_flutter.dart';

/// =========================
/// STATE
/// =========================
class ProfileState {
  final Map<String, dynamic>? profile;
  final User? user;
  final bool loading;
  final bool initialized;
  final String? error;

  const ProfileState({
    this.profile,
    this.user,
    this.loading = false,
    this.initialized = false,
    this.error,
  });

  ProfileState copyWith({
    Map<String, dynamic>? profile,
    User? user,
    bool? loading,
    bool? initialized,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      user: user ?? this.user,
      loading: loading ?? this.loading,
      initialized: initialized ?? this.initialized,
      error: error,
    );
  }
}
