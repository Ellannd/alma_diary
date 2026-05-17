import 'package:alma_diary/features/profile/domain/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//Sólo lógica de estado de APP  (cargando datos, validando, etc) para manejo de datos 
//esta el Profile de features/profile/domain/profile.dart que es el modelo de datos. 
//El controller se encarga de manejar la lógica de negocio y actualizar el estado, 
//mientras que el state es una clase inmutable que representa el estado actual del perfil en la aplicación.

class ProfileState {
  final Profile? profile;
  final User? user;
  final bool isLoading;
  final bool initialized;
  final String? error;

  const ProfileState({
    this.profile,
    this.user,
    this.isLoading = false,
    this.initialized = false,
    this.error,
  });

  ProfileState copyWith({
    Profile? profile,
    User? user,
    bool? isLoading,
    bool? initialized,
    bool? onboardingCompleted,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
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