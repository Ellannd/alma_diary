import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alma_diary/state/auth/auth_controller.dart';

import 'auth_screen.dart';
import '../../dashboard/screen/dashboard_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    if (auth.isAuthenticated) {
      return const DashboardScreen();
    }

    return const AuthScreen();
  }
}