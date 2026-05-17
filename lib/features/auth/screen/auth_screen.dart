import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alma_diary/state/auth/auth_controller.dart';
import 'package:alma_diary/core/navigation/app_routes.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

import '../widgets/auth_glass_container.dart';
import '../widgets/auth_title.dart';
import '../widgets/auth_input.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_social_buttons.dart';
import '../widgets/auth_divider.dart';
import 'package:alma_diary/design_system/components/feedback/alma_feedback.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();

  bool _isLogin = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  void _toggleMode() => setState(() => _isLogin = !_isLogin);

  Future<void> _submit(AuthController controller) async {
    if (_email.text.isEmpty || _password.text.isEmpty) return;
    if (!_isLogin && !_acceptedTerms) return;

    if (_isLogin) {
      await controller.signInWithEmail(
        email: _email.text.trim(),
        password: _password.text,
      );
    } else {
      await controller.signUpWithEmail(
        email: _email.text.trim(),
        password: _password.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(authControllerProvider, (previous, next) {
      next.whenData((authState) {
        if (authState.isAuthenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        }
      });
    });

    final state = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);
    final isLoading = state.asData?.value.isLoading ?? false;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AuthGlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo centrado
                  const Center(child: AuthTitle()),
                  const SizedBox(height: 32),

                  // Email
                  AuthInput(controller: _email, hint: 'Correo electrónico'),
                  SizedBox(height: AlmaSpacing.r(context, 16)),

                  // Nombre solo en registro
                  if (!_isLogin) ...[
                    AuthInput(controller: _name, hint: 'Nombre'),
                    SizedBox(height: AlmaSpacing.r(context, 16)),
                  ],

                  // Contraseña
                  AuthInput(
                    controller: _password,
                    hint: 'Contraseña',
                    obscure: true,
                  ),

                  // Olvidaste contraseña solo en login
                  if (_isLogin) ...[
                    SizedBox(height: AlmaSpacing.r(context, 16)),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: AlmaTypography.labelSmall(isDark, context).copyWith(
                            color: AlmaColors.textMuted(isDark),
                            fontSize: AlmaSpacing.r(context, 14),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Checkbox términos solo en registro
                  if (!_isLogin) ...[
                    SizedBox(height: AlmaSpacing.r(context, 16)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: Checkbox(
                            value: _acceptedTerms,
                            onChanged: (v) =>
                                setState(() => _acceptedTerms = v ?? false),
                            activeColor: AlmaColors.accent(isDark),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        SizedBox(width: AlmaSpacing.r(context, 16)),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: AlmaTypography.bodySmall(isDark, context).copyWith(
                                color: AlmaColors.textSecondary(isDark),
                              ),
                              children: [
                                const TextSpan(text: 'Acepto los '),
                                TextSpan(
                                  text: 'Términos',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: AlmaColors.textPrimary(isDark),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(text: ' y la '),
                                TextSpan(
                                  text: 'Política de privacidad',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: AlmaColors.textPrimary(isDark),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  SizedBox(height: AlmaSpacing.r(context, 20)),

                  // Botón principal
                  AuthButton(
                    text: _isLogin ? 'Iniciar sesión' : 'Crear cuenta',
                    loading: isLoading,
                    onPressed: () => _submit(controller),
                  ),

                  // Error
                  if (state.asData?.value.error != null) ...[
                    SizedBox(height: AlmaSpacing.r(context, 12)),
                    AlmaFeedback(
                      message: state.asData!.value.error!,
                      type: AlmaFeedbackType.error,
                    ),
                  ],

                  SizedBox(height: AlmaSpacing.r(context, 26)),

                  AuthDivider(
                    label: _isLogin ? 'Ingresa con' : 'Regístrate con',
                  ),
                  SizedBox(height: AlmaSpacing.r(context, 26)),

                  AuthSocialButtons(
                    loading: isLoading,
                    onGoogle: isLoading ? null : controller.signInWithGoogle,
                   // onFacebook: isLoading ? null : controller.signInWithFacebook,
                  //  onApple: isLoading ? null : controller.signInWithApple,
                  ),

                  SizedBox(height: AlmaSpacing.r(context, 26)),

                  // Toggle login/registro
                  Center(
                    child: TextButton(
                      onPressed: _toggleMode,
                      child: RichText(
                        text: TextSpan(
                          style: AlmaTypography.bodySmall(isDark, context).copyWith(
                            color: AlmaColors.textMuted(isDark),
                          ),
                          children: [
                            TextSpan(
                              text: _isLogin
                                  ? '¿No tienes una cuenta? '
                                  : '¿Ya tienes cuenta? ',
                            ),
                            TextSpan(
                              text: _isLogin ? 'Regístrate' : 'Inicia sesión',
                              style: TextStyle(
                                color: AlmaColors.textPrimary(isDark),
                                fontWeight: FontWeight.w700,
                                fontSize: AlmaSpacing.r(context, 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}