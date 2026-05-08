import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alma_diary/state/auth/auth_controller.dart';

import '../widgets/auth_glass_container.dart';
import '../widgets/auth_title.dart';
import '../widgets/auth_input.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_google_button.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_footer.dart';

import 'package:alma_diary/design_system/components/feedback/alma_feedback.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  bool isLogin = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  void _submit(AuthController controller) {
    if (email.text.isEmpty || password.text.isEmpty) return;

    if (isLogin) {
      controller.signInWithEmail(
        email: email.text,
        password: password.text,
      );
    } else {
      controller.signUpWithEmail(
        email: email.text,
        password: password.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    final isLoading = state.isLoading;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AuthGlassContainer(
              child: Column(
                children: [
                  const AuthTitle(),
                  const SizedBox(height: 32),

                  AuthInput(controller: email, hint: "Email"),
                  const SizedBox(height: 12),

                  AuthInput(
                    controller: password,
                    hint: "Contraseña",
                    obscure: true,
                  ),

                  const SizedBox(height: 18),

                  AuthButton(
                    text: isLogin ? "Entrar" : "Crear cuenta",
                    loading: isLoading,
                    onPressed: isLoading ? null : () => _submit(controller),
                  ),

                  const SizedBox(height: 12),

                  if (state.error != null) ...[
                    AlmaFeedback(
                      message: state.error!,
                      type: AlmaFeedbackType.error,
                    ),
                  ],

                  const SizedBox(height: 8),

                  TextButton(
                    onPressed: _toggleMode,
                    child: Text(
                      isLogin
                          ? "¿No tienes cuenta? Regístrate"
                          : "¿Ya tienes cuenta? Inicia sesión",
                    ),
                  ),

                  const SizedBox(height: 20),
                  const AuthDivider(),
                  const SizedBox(height: 20),

                  AuthGoogleButton(
                    loading: isLoading,
                    onPressed: isLoading
                        ? null
                        : controller.signInWithGoogle,
                  ),

                  const SizedBox(height: 20),
                  const AuthFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}