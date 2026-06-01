import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alma_diary/state/auth/auth_controller.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';
import '../widgets/auth_glass_container.dart';
import '../widgets/auth_title.dart';
import '../widgets/auth_input.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_social_buttons.dart';
import '../widgets/auth_divider.dart';
import '../widgets/password_strength_indicator.dart';
import 'package:alma_diary/design_system/components/feedback/alma_feedback.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();

  bool _isLogin = true;
  bool _acceptedTerms = false;

  // Validaciones inline
  AuthInputValidation _emailValidation = AuthInputValidation.none;
  AuthInputValidation _passwordValidation = AuthInputValidation.none;
  AuthInputValidation _nameValidation = AuthInputValidation.none;
  String? _emailError;

  // Fuerza contraseña (solo registro)
  String _passwordText = '';

  @override
  void initState() {
    super.initState();
    _password.addListener(() {
      setState(() => _passwordText = _password.text);
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  // ── Validaciones ────────────────────────────────────────────────────────────

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim());

  void _validateEmail() {
    final v = _email.text.trim();
    setState(() {
      if (v.isEmpty) {
        _emailValidation = AuthInputValidation.none;
        _emailError = null;
      } else if (_isValidEmail(v)) {
        _emailValidation = AuthInputValidation.valid;
        _emailError = null;
      } else {
        _emailValidation = AuthInputValidation.invalid;
        _emailError = 'Correo inválido';
      }
    });
  }

  void _validatePassword() {
    final v = _password.text;
    setState(() {
      if (v.isEmpty) {
        _passwordValidation = AuthInputValidation.none;
      } else if (_isLogin) {
        _passwordValidation = v.length >= 6
            ? AuthInputValidation.valid
            : AuthInputValidation.invalid;
      } else {
        // En registro: mínimo fuerte
        final strength = PasswordStrengthIndicator.evaluate(v);
        _passwordValidation = strength == PasswordStrength.strong
            ? AuthInputValidation.valid
            : strength == PasswordStrength.medium
                ? AuthInputValidation.none
                : AuthInputValidation.invalid;
      }
    });
  }

  void _validateName() {
    setState(() {
      _nameValidation = _name.text.trim().length >= 2
          ? AuthInputValidation.valid
          : AuthInputValidation.invalid;
    });
  }

  // ── Toggle modo ─────────────────────────────────────────────────────────────

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      // Reset validaciones al cambiar modo
      _emailValidation = AuthInputValidation.none;
      _passwordValidation = AuthInputValidation.none;
      _nameValidation = AuthInputValidation.none;
      _emailError = null;
    });
  }

  // ── Submit ──────────────────────────────────────────────────────────────────

  bool get _canSubmit {
    if (_email.text.isEmpty || _password.text.isEmpty) return false;
    if (!_isLogin && !_acceptedTerms) return false;
    if (!_isLogin && _name.text.trim().isEmpty) return false;
    if (_emailValidation == AuthInputValidation.invalid) return false;
    return true;
  }

  Future<void> _submit(AuthController controller) async {
    if (!_canSubmit) return;

    if (_isLogin) {
      await controller.signInWithEmail(
        email: _email.text.trim(),
        password: _password.text,
      );
    } else {
      await controller.signUpWithEmail(
        email: _email.text.trim(),
        password: _password.text,
        name: _name.text.trim(),
      );

      if (!mounted) return;
      _showEmailConfirmationDialog();
    }
  }

  // ── Forgot password ─────────────────────────────────────────────────────────

  void _showForgotPassword(AuthController controller) {
    final resetEmail = TextEditingController(text: _email.text.trim());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Recuperar contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Te enviaremos un enlace para restablecer tu contraseña.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await controller.resetPassword(email: resetEmail.text.trim());
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Revisa tu correo para restablecer tu contraseña.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void _showEmailConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Revisa tu correo'),
        content: const Text(
          'Te enviamos un enlace de confirmación. '
          'Una vez confirmado, ya puedes iniciar sesión.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (mounted) setState(() => _isLogin = true);
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);
    final isLoading = authState.isLoading;

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

                  // ── Logo ──────────────────────────────────────────────────
                  const Center(child: AuthTitle()),
                  const SizedBox(height: 32),

                  // ── Email ─────────────────────────────────────────────────
                  AuthInput(
                    controller: _email,
                    hint: 'Correo electrónico',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validation: _emailValidation,
                    errorText: _emailError,
                    onEditingComplete: _validateEmail,
                  ),
                  SizedBox(height: AlmaSpacing.r(context, 16)),

                  // ── Nombre (solo registro, animado) ───────────────────────
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _isLogin
                        ? const SizedBox.shrink()
                        : Column(
                            children: [
                              AuthInput(
                                controller: _name,
                                hint: 'Nombre',
                                textInputAction: TextInputAction.next,
                                validation: _nameValidation,
                                onEditingComplete: _validateName,
                              ),
                              SizedBox(height: AlmaSpacing.r(context, 16)),
                            ],
                          ),
                  ),

                  // ── Contraseña ────────────────────────────────────────────
                  AuthInput(
                    controller: _password,
                    hint: 'Contraseña',
                    obscure: true,
                    validation: _passwordValidation,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: _validatePassword,
                  ),

                  // ── Fuerza contraseña (solo registro, animado) ────────────
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: !_isLogin && _passwordText.isNotEmpty
                        ? PasswordStrengthIndicator(password: _passwordText)
                        : const SizedBox.shrink(),
                  ),

                  // ── Olvidaste contraseña (solo login) ─────────────────────
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: _isLogin
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(height: AlmaSpacing.r(context, 16)),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => _showForgotPassword(controller),
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
                          )
                        : const SizedBox.shrink(),
                  ),

                  // ── Términos (solo registro, animado) ─────────────────────
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _isLogin
                        ? const SizedBox.shrink()
                        : Column(
                            children: [
                              SizedBox(height: AlmaSpacing.r(context, 16)),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Checkbox(
                                      value: _acceptedTerms,
                                      onChanged: (v) => setState(
                                          () => _acceptedTerms = v ?? false),
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
                          ),
                  ),

                  SizedBox(height: AlmaSpacing.r(context, 20)),

                  // ── Botón principal ───────────────────────────────────────
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _canSubmit ? 1.0 : 0.5,
                    child: AuthButton(
                      text: _isLogin ? 'Iniciar sesión' : 'Crear cuenta',
                      loading: isLoading,
                      onPressed: isLoading ? null : () => _submit(controller),
                    ),
                  ),

                  // ── Error ─────────────────────────────────────────────────
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: authState.error != null
                        ? Column(
                            children: [
                              SizedBox(height: AlmaSpacing.r(context, 12)),
                              AlmaFeedback(
                                message: authState.error!,
                                type: AlmaFeedbackType.error,
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),

                  SizedBox(height: AlmaSpacing.r(context, 26)),

                  // ── Divider ───────────────────────────────────────────────
                  AuthDivider(
                    label: _isLogin ? 'Ingresa con' : 'Regístrate con',
                  ),
                  SizedBox(height: AlmaSpacing.r(context, 26)),

                  // ── Social buttons ────────────────────────────────────────
                  AuthSocialButtons(
                    loading: isLoading,
                    onGoogle: isLoading ? null : controller.signInWithGoogle,
                  ),

                  SizedBox(height: AlmaSpacing.r(context, 26)),

                  // ── Toggle login/registro ─────────────────────────────────
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