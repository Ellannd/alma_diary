import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alma_diary/state/profile/profile_controller.dart';
import 'package:alma_diary/features/onboarding/controller/onboarding_controller.dart';
import 'package:alma_diary/core/logging/log_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final String userId;
  final VoidCallback onComplete;
  final String? initialName;

  const OnboardingScreen({
    super.key,
    required this.userId,
    required this.onComplete,
    this.initialName,
  });

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  String? _emotionalState;
  String? _painPoint;
  String? _hopefulGoal;
  String? _mainChallenge;
  String? _name;

  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.initialName ?? '');

    _nameController.addListener(() {
      
      setState(() => _name = _nameController.text.trim());
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    try {
      LogService.instance.info('onboarding.complete.start');

      final controller = OnboardingController(
        ref.read(profileRepositoryProvider),
      );

      await controller.completeOnboarding(
        emotionalState: _emotionalState!,
        painPoint: _painPoint!,
        hopefulGoal: _hopefulGoal!,
        mainChallenge: _mainChallenge,
        name: _name,
      );

      widget.onComplete();
    } catch (e, st) {
      LogService.instance.error(
        'onboarding.complete.failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => _currentPage = i),
        children: [
          _intro(color),
          _nameStep(color),
          _emotionStep(color),
          _painStep(color),
          _goalStep(color),
        ],
      ),
    );
  }

  Widget _intro(ColorScheme color) {
    return _step(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.spa, size: 90, color: color.primary),
          const SizedBox(height: 24),
          Text(
            'Estás a punto de empezar algo importante',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: color.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _next,
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  Widget _nameStep(ColorScheme color) {
    return _step(
      child: Column(
        children: [
          Text(
            '¿Cómo quieres que te llamemos?',
            style: TextStyle(color: color.onSurface, fontSize: 18),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Tu nombre',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _nameController.text.trim().isEmpty ? null : _next,
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  Widget _emotionStep(ColorScheme color) {
    return _step(
      child: Column(
        children: [
          const Text('¿Cómo te sientes hoy?'),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            children: [
              _chip('claro'),
              _chip('parcial'),
              _chip('nublado'),
              _chip('tormenta'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _painStep(ColorScheme color) {
    return _step(
      child: Column(
        children: [
          const Text('¿Qué te pesa más?'),
          const SizedBox(height: 20),
          _option('estrés'),
          _option('vacío'),
          _option('confusión'),
        ],
      ),
    );
  }

  Widget _goalStep(ColorScheme color) {
    return _step(
      child: Column(
        children: [
          const Text('¿Qué buscas aquí?'),
          const SizedBox(height: 20),
          _option('paz'),
          _option('orden'),
          _option('acompañamiento'),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: (_emotionalState != null &&
                    _painPoint != null &&
                    _hopefulGoal != null)
                ? _finish
                : null,
            child: const Text('Terminar'),
          ),
        ],
      ),
    );
  }

  Widget _chip(String value) {
    final selected = _emotionalState == value;

    return ChoiceChip(
      label: Text(value),
      selected: selected,
      onSelected: (_) {
        setState(() => _emotionalState = value);
        _next();
      },
    );
  }

  Widget _option(String value) {
    final selected =
        _painPoint == value || _hopefulGoal == value;

    return ListTile(
      title: Text(value),
      selected: selected,
      onTap: () {
        setState(() {
          if (_painPoint == null) {
            _painPoint = value;
          } else {
            _hopefulGoal = value;
          }
        });
        _next();
      },
    );
  }

  Widget _step({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(child: child),
    );
  }
}