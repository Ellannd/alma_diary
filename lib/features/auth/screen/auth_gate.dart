import 'package:alma_diary/design_system/components/feedback/alma_loader.dart';

import 'package:alma_diary/features/onboarding/screen/onboarding_screen.dart';

import 'package:alma_diary/state/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'auth_screen.dart';
import '../../dashboard/screen/dashboard_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Escuchamos el usuario reactivo
    final user = ref.watch(currentUserProvider);

 

    // 2. Si no hay sesión, directo al login
    if (user == null) {
    
      return const AuthScreen();
    }

    // 3. Si hay sesión, escuchamos el perfil
    final profileAsync = ref.watch(profileControllerProvider);


    return profileAsync.when(
      loading: () {
  
        return _loading();
      },
      error: (e, stack) {

        return Scaffold(
          body: Center(child: Text('Error al inicializar sesión: $e')),
        );
      },
      data: (profile) {

        
        // Si el perfil no se ha creado o no terminó onboarding
        if (profile == null || !profile.isOnboardingComplete) { 
          return const OnboardingScreen();
        }
        
        // Todo listo
        return const DashboardScreen();
      },
    );
  }

  Widget _loading() => const Scaffold(
        body: Center(child: AlmaLoader()),
      );
}
