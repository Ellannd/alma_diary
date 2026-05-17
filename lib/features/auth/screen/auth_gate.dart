import 'package:alma_diary/features/onboarding/screen/onboarding_screen.dart';
import 'package:alma_diary/state/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alma_diary/state/auth/auth_controller.dart';

import 'auth_screen.dart';
import '../../dashboard/screen/dashboard_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final profileState = ref.watch(profileControllerProvider);

    final auth = authState.asData?.value;
    final profile = profileState.profile;

    // 1. loading
    if (authState.isLoading || profileState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. not authenticated
    if (auth?.isAuthenticated != true) {
      return const AuthScreen();
    }

    // 3. dispara loadProfile si no está inicializado
    if (!profileState.initialized) {
      // WidgetsBinding para no llamar durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(profileControllerProvider.notifier)
            .loadProfile(auth!.user!.id);
      });

      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 4. profile loading
    if (profileState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 5. onboarding check
    if (profile == null || !profile.isOnboardingComplete) {
      return const OnboardingScreen();
    }

    // 5. app
    return const DashboardScreen();
  }
}
