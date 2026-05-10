import 'package:flutter/material.dart';
import 'package:alma_diary/core/logging/log_service.dart';
import "package:alma_diary/features/profile/data/profile_repository.dart";
import "controller/onboarding_controller_old.dart";

class OnboardingScreen extends StatefulWidget {
  final String userId;
  final VoidCallback onComplete;
  final String? initialName;
  const OnboardingScreen({super.key, required this.userId, required this.onComplete, this.initialName});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final bool _isLoading = false;

  String? _emotionalState;
  String? _painPoint;
  String? _hopefulGoal;
  String? _mainChallenge;
  String? _name;

  late AnimationController _gradientController;
  late final OnboardingController _controller;
  late TextEditingController _nameController;
  late Animation<Alignment> _gradientBegin;
  late Animation<Alignment> _gradientEnd;

  @override
  void initState() {
    super.initState();
    _controller = OnboardingController(ProfileRepository());
    //si viene un nombre desde el perfil, lo usamos para prellenar el campo y la variable
    _nameController =  _nameController = TextEditingController(
    text: widget.initialName ?? '');

    _nameController.addListener(() {
    setState(() {});
  });

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _gradientBegin = TweenSequence<Alignment>([
      TweenSequenceItem(tween: Tween(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.bottomLeft, end: Alignment.topLeft), weight: 1),
    ]).animate(_gradientController);
    
    _gradientEnd = TweenSequence<Alignment>([
      TweenSequenceItem(tween: Tween(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.bottomLeft, end: Alignment.topLeft), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1),
      TweenSequenceItem(tween: Tween(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1),
    ]).animate(_gradientController);
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

 Future<void> _saveOnboarding() async {
    try {
      LogService.instance.info('onboarding.save.start');

      await _controller.completeOnboarding(
        emotionalState: _emotionalState!,
        painPoint: _painPoint!,
        hopefulGoal: _hopefulGoal!,
        mainChallenge: _mainChallenge,
        preferredLanguage: null,
        stressLevel: null,
        sleepQuality: null,
        name: _name,
      );

      LogService.instance.info('onboarding.save.success');

      widget.onComplete();

    } catch (e, st) {
      LogService.instance.error(
        'onboarding.save.failed',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _gradientBegin.value,
                end: _gradientEnd.value,
                colors: [
                  Theme.of(context).scaffoldBackgroundColor,
                  Theme.of(context).cardColor,
                  Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
                ],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: _currentPage == index ? 32 : 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _currentPage == index 
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: _currentPage == index
                            ? [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                    );
                  }),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Cada una de estas funciones construye el contenido de cada página del onboarding
                    _buildValidationPage(),
                    _buildNamePage(),
                    _buildEmotionalStatePage(),
                    _buildPainPointPage(),
                    _buildHopefulGoalPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValidationPage() {
    return _buildPageContent(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Icon(
              Icons.spa_outlined,
              size: 100,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 40),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(opacity: value, child: child);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'A veces, el ruido del día a día —los estudios, el trabajo, las responsabilidades— no nos deja escucharnos a nosotros mismos.',
                style: TextStyle(fontSize: 20, color: Colors.white70, height: 1.6),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(opacity: value, child: child);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Estás aquí porque buscas un refugio, y ya lo encontraste.',
                style: TextStyle(fontSize: 20, color: Colors.white70, height: 1.6),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 60),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Necesito este espacio',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          ),
        ],
      ),
    );
  }

    Widget _buildNamePage() {
    return _buildPageContent(
      title: '¿Cómo quieres que te llamemos?',
      subtitle: 'Este será tu espacio personal',
      content: Column(
        children: [
          TextField(
            controller: _nameController,
            onChanged: (value) => _name = value.trim(),
            decoration: InputDecoration(
              hintText: 'Tu nombre',
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: (_nameController.text.trim().isNotEmpty)
                ? _nextPage
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

 Widget _buildEmotionalStatePage() {
  return _buildPageContent(
    title: '¿Cómo está tu clima interior hoy?',
    subtitle: 'Elige el icono que mejor te represente',
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            _buildClimateOption(Icons.wb_sunny, 'Claro', 'claro'),
            _buildClimateOption(Icons.cloud, 'Parcial', 'parcial'),
            _buildClimateOption(Icons.cloud_queue, 'Nublado', 'nublado'),
            _buildClimateOption(Icons.thunderstorm, 'Tormentoso', 'tormentoso'),
          ],
        ),

        const SizedBox(height: 32),

        if (_emotionalState != null)
          _buildSelectedFeedback(_emotionalState!),
      ],
    ),
  );
}

Widget _buildClimateOption(IconData icon, String label, String value) {
  final isSelected = _emotionalState == value;

  return GestureDetector(
    onTap: () {
      setState(() => _emotionalState = value);
      Future.delayed(const Duration(milliseconds: 300), _nextPage);
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.25)
            : Theme.of(context).cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          width: 2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: isSelected ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              icon,
              size: 40,
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildPainPointPage() {
    return _buildPageContent(
      title: '¿Qué peso vienes a soltar en este diario?',
      content: Column(
        children: [
          _buildOption(
            icon: Icons.track_changes,
            label: 'El peso de mis metas futuras',
            value: 'metas_futuras',
          ),
          _buildOption(
            icon: Icons.today,
            label: 'La dificultad de vivir el presente',
            value: 'presente',
          ),
          _buildOption(
            icon: Icons.psychology_outlined,
            label: 'La falta de un lugar donde ser honesto conmigo mismo',
            value: 'honestidad',
          ),
          _buildOption(
            icon: Icons.battery_0_bar,
            label: 'El cansancio físico y mental',
            value: 'cansancio'),
        ],
      ),
    );
  }

  Widget _buildHopefulGoalPage() {
    return _buildPageContent(
      title: '¿Qué luz buscas encontrar en Alma?',
      content: Column(
        children: [
          _buildOption(
            icon: Icons.nightlight_round,
            label: 'Paz',
            description: 'Saber que mis pensamientos están a salvo',
            value: 'paz',
          ),
          _buildOption(
            icon: Icons.grid_view_rounded,
            label: 'Orden',
            description: 'Ver mis ideas con más estructura',
            value: 'orden',
          ),
          _buildOption(
            icon: Icons.people_outline,
            label: 'Compañía',
            description: 'Sentir que alguien me escucha',
            value: 'companero',
          ),
          const SizedBox(height: 32),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: (_emotionalState != null && _painPoint != null && _hopefulGoal != null) ? 1.0 : 0.5,
            child: ElevatedButton(
              onPressed: (_emotionalState != null && _painPoint != null && _hopefulGoal != null)
                  ? _saveOnboarding
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Text('Comenzar mi viaje', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent({String? title, String? subtitle, required Widget content}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 16, color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 32),
            ],
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    String? description,
    required String value,
  }) {
    final isSelected = _currentPage == 3
        ? _painPoint == value
        : _hopefulGoal == value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_currentPage == 3) {
              _painPoint = value;
            } else {
              _hopefulGoal = value;
            }
          });
          if (_currentPage < 4) {
            Future.delayed(const Duration(milliseconds: 250), _nextPage);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                : Theme.of(context).cardColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white54, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(fontSize: 13, color: Colors.white54),
                      ),
                    ],
                  ],
                ),
              ),
              AnimatedScale(
                scale: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedFeedback(String state) {
    final feedbacks = {
      'claro': 'Siento claridad y energía positiva',
      'parcial': 'Tengo momentos buenos y otros complejos',
      'nublado': 'Necesito que el cielo se abra',
      'tormentoso': 'Hay mucho dentro de mí que quiere salir, pero no sé cómo',
    };
    
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.favorite_outline, color: Theme.of(context).colorScheme.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feedbacks[state] ?? '',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}