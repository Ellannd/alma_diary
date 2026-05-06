import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import "package:alma_diary/state/auth/auth_app_state.dart";
import 'package:alma_diary/state/auth/auth_controller.dart';


/// =========================
/// PROVIDER (CONTROLLER STATE)
/// =========================
final authControllerProvider =
    NotifierProvider<AuthController, AuthAppState>(
  AuthController.new,
);

/// =========================
/// OPTIONAL: SUPABASE DEPENDENCY PROVIDER
/// =========================
/// (buena práctica para desacoplar Supabase del controller)
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});