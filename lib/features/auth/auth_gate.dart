import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alma_diary/features/profile/controller/profile_controller.dart';
import 'package:alma_diary/features/dashboard/alma_dashboard.dart';
import 'package:alma_diary/features/onboarding/onboarding_screen.dart';
import 'package:alma_diary/features/profile/data/profile_repository.dart';
import 'package:alma_diary/features/notifications/controller/notifications_controller.dart';
import 'package:alma_diary/core/session/auth_session_service.dart';
import "auth_orchestrator.dart";
import 'auth_controller.dart';
import "data/auth_repository.dart";

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;

        if (session == null) {
          return const LoginScreen();
        }

        return _ProfileGate(
          key: ValueKey(session.user.id), // CLAVE IMPORTANTE
          userId: session.user.id,
          onOnboardingComplete: () {},
        );
      },
    );
  }
}

class _ProfileGate extends StatefulWidget {
  final String userId;
  final VoidCallback onOnboardingComplete;


  const    _ProfileGate({
    super.key,
    required this.userId,
    required this.onOnboardingComplete,
  });

  @override
  State<_ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<_ProfileGate> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  bool _hasError = false;
  late final AuthOrchestrator _orchestrator;
  late final AuthController _authController;

  late final AuthSessionService _session;


  @override
  void initState() {
    super.initState();

    _session = AuthSessionService(Supabase.instance.client);
    
    _orchestrator = AuthOrchestrator(
    ProfileController(ProfileRepository()),
    NotificationController(Supabase.instance.client),
  );

    _authController = AuthController(AuthRepository());

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = widget.userId;
     
    try {
        if (!mounted) return;

        final profile = await _orchestrator.loadUserSession(
          userId: userId,
        );

        if (!mounted) return;

        setState(() {
          _profile = profile;
          _isLoading = false;
          _hasError = false;
        });
      } catch (e) {
        if (!mounted) return;

        setState(() {
          _hasError = true;
          _isLoading = false;
        });
  }
}


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_hasError) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Error al cargar perfil',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                  });
                  _loadProfile();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final isOnboardingComplete = _profile?['is_onboarding_complete'] ?? false;

    if (!isOnboardingComplete) {
      return OnboardingScreen(
        userId: widget.userId,
         onComplete: () async {
          await _loadProfile(); // Recargar perfil para reflejar el cambio
        },
         initialName: _authController.currentUser?.userMetadata?['name']??'',
      );
    }

    return const AlmaDashboard();
  }
}


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();


  bool _isRegister = false;

  @override
  void initState() {

    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showError(String message) {
  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

  Future<void> _signInWithGoogle() async {
  setState(() => _isLoading = true);

  try {
    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.google,
    );
  } catch (e) {
    _showError('Error al iniciar sesión');
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  Future<void> _handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Completa todos los campos');
      return;
    }

    setState(() => _isLoading = true);

    try {

      if (_isRegister) {
        final res = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );

        if (res.session == null) {

          if (mounted) {
            // requiere confirmación por email
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Revisa tu correo para confirmar tu cuenta'),
              ),
            );
            setState(() {
            _isRegister = false;
          });

          } else {

            if (mounted){
            // login automático (si desactivas confirmación)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cuenta creada correctamente'),
              ),
            );

            }
          }
        }
      } else {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      }
    } catch (e) {
      _showError('Error de autenticación');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: child,
                ),
              );
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  _buildHeader(),

                  const SizedBox(height: 40),

                  _buildEmailForm(),

                  const SizedBox(height: 16),

                  _buildEmailButton(),

                  _buildToggle(),

                  const SizedBox(height: 24),

                  _buildDivider(),

                  const SizedBox(height: 24),

                  _buildGoogleButton(),

                  const SizedBox(height: 24),

                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildHeader() {
    return Column(
      children: [
        Hero(
          tag: 'alma_logo',
          child: Icon(
            Icons.self_improvement,
            size: 90,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 20),
        Hero(
          tag: 'alma_title',
          child: Material(
            color: Colors.transparent,
            child: Text(
              'Alma Diary',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                shadows: [
                  Shadow(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Escribe. Sana. Vive.\nTu espacio seguro para reflexionar y crecer.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: 'Email',
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Contraseña',
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleEmailAuth,
        child: Text(
          _isRegister ? 'Crear cuenta' : 'Iniciar sesión',
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return TextButton(
      onPressed: () {
        setState(() => _isRegister = !_isRegister);
      },
      child: Text(
        _isRegister
            ? '¿Ya tienes cuenta? Inicia sesión'
            : '¿No tienes cuenta? Regístrate',
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: const [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('o'),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signInWithGoogle,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.g_mobiledata, size: 28),
                  SizedBox(width: 8),
                  Text('Continuar con Google'),
                ],
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'Al continuar, aceptas nuestros Términos\ny Política de Privacidad',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        color: Theme.of(context)
            .colorScheme
            .onSurface
            .withValues(alpha: 0.5),
      ),
    );
  }
}