import 'package:alma_diary/features/profile/domain/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileState {
  final Profile? profile;
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
    Profile? profile,
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
  
    String get displayName {
    final fullName = profile?.displayName ??
        user?.userMetadata?['name'] ??
        user?.email;

    if (fullName == null || fullName.isEmpty) return 'Usuario';
    return fullName.split(RegExp(r'\s+')).first;
  }

}