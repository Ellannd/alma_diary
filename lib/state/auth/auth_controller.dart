import "dart:async";

import "package:alma_diary/core/analytics/auth_analytics.dart";
import "package:alma_diary/core/logging/log_service.dart";
import "package:alma_diary/services/fcm_listener_service.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import "package:alma_diary/state/auth/auth_app_state.dart";
import "package:alma_diary/features/auth/data/auth_repository.dart";



/// =========================
/// PROVIDERS
/// =========================
final authControllerProvider = NotifierProvider<AuthController, AuthAppState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthAppState> {
  @override
  AuthAppState build() => AuthAppState.initial();

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      AuthAnalytics.onAuthSuccess(response.user!.id);
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error inesperado');
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await AuthRepository()
          .signUpWithEmail(email, password, name: name);

      if (result == SignUpResult.needsEmailConfirmation) {
        state = state.copyWith(isLoading: false, needsEmailConfirmation: true);
        return;
      }
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await AuthRepository().signInWithGoogle();
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) AuthAnalytics.onAuthSuccess(userId);
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error inesperado');
    }
  }


  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await FcmService.instance.deregisterDevice(user.id);
      }
      AuthAnalytics.onAuthSignOut();
      await Supabase.instance.client.auth.signOut();
      state = AuthAppState.initial();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error al cerrar sesión');
    }
  }

  void clearError() => state = state.copyWith(error: null);

  Future<void> resetPassword({required String email}) async {
  try {
    await Supabase.instance.client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'com.alma.diario://reset-callback',
    );
    LogService.instance.info('auth.reset_password_sent', context: {'email': email});
  } catch (e, st) {
    LogService.instance.error('auth.reset_password_failed', error: e, stackTrace: st);
  }
}
}