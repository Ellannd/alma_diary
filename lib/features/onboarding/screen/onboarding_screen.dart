import 'package:alma_diary/design_system/components/feedback/alma_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';
import 'package:alma_diary/state/profile/profile_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

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
  String? _name;

  late TextEditingController _nameController;

  static const _totalPages = 5;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileControllerProvider).value;
    final initialName = profile?.displayName ?? '';
    _nameController = TextEditingController(text: initialName);
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
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

Future<void> _finish() async {
  try {

    final archetype = _deriveArchetype(_emotionalState, _painPoint);

    await ref.read(profileControllerProvider.notifier).completeOnboarding(
        emotionalState: _emotionalState!,
        painPoint: _painPoint!,
        hopefulGoal: _hopefulGoal!,
        name: _name,
         archetype: archetype,
         painNodes: [_painPoint!], // los nodos de dolor son el painPoint por ahora
      );

    // reload() no es necesario — completeOnboarding ya actualiza el state
    // AuthGate redirige solo al ver isOnboardingComplete = true

  } catch (e, st) {
    LogService.instance.error(
      'onboarding.complete.failed',
      error: e,
      stackTrace: st,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar. Intenta de nuevo.')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // USA EL PROVIDER CORRECTO Y REACTIVO, EL MISMO QUE USA AUTHGATE PARA DECIDIR MOSTRAR ONBOARDING O DASHBOARD
    final userId = ref.watch(currentUserProvider)?.id;

    if (userId == null) {
      return const Scaffold(body: Center(child: AlmaLoader()));
    }

    final progress = (_currentPage + 1) / _totalPages;

    return Scaffold(
      backgroundColor: AlmaColors.background(isDark),
      body: SafeArea(
        child: Column(
          children: [
            // =====================
            // PROGRESS BAR
            // =====================
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AlmaSpacing.r(context, AlmaSpacing.lg),
                vertical: AlmaSpacing.r(context, AlmaSpacing.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${(_currentPage + 1) * (100 ~/ _totalPages)}%',
                    style: AlmaTypography.labelSmall(isDark, context).copyWith(
                      color: AlmaColors.textMuted(isDark),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AlmaRadius.full),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 3,
                      backgroundColor: AlmaColors.surfaceVariant(isDark),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AlmaColors.textPrimary(isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =====================
            // PAGES
            // =====================
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _introStep(isDark),
                  _nameStep(isDark),
                  _emotionStep(isDark),
                  _painStep(isDark),
                  _goalStep(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================
  // SHARED LAYOUT
  // =====================
  Widget _stepShell({
    required bool isDark,
    required String question,
    required Widget body,
    IconData? icon,
    Widget? action,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AlmaSpacing.r(context, AlmaSpacing.xl),
        vertical: AlmaSpacing.r(context, AlmaSpacing.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          SizedBox(height: AlmaSpacing.r(context, AlmaSpacing.xxl)),

          if (icon != null) ...[
            Icon(icon, size: 32, color: AlmaColors.textMuted(isDark)),
            SizedBox(height: AlmaSpacing.r(context, AlmaSpacing.md)),
          ],

          Text(
            question,
            style: AlmaTypography.displayMedium(isDark, context).copyWith(
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),

          SizedBox(height: AlmaSpacing.r(context, AlmaSpacing.lg)),

          Expanded(child: body),

          if (action != null) ...[
            SizedBox(height: AlmaSpacing.r(context, AlmaSpacing.md)),
            action,
          ],

          SizedBox(height: AlmaSpacing.r(context, AlmaSpacing.sm)),
        ],
      ),
    );
  }

  // =====================
  // OPTION TILE
  // =====================
  Widget _optionTile({
    required bool isDark,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AlmaSpacing.r(context, AlmaSpacing.md),
          vertical: AlmaSpacing.r(context, AlmaSpacing.md),
        ),
        decoration: BoxDecoration(
          color: selected
              ? AlmaColors.textPrimary(isDark)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AlmaRadius.input),
          border: Border.all(
            color: selected
                ? AlmaColors.textPrimary(isDark)
                : AlmaColors.textMuted(isDark).withValues(alpha: .4),
          ),
        ),
        child: Text(
          label,
          style: AlmaTypography.bodyLarge(isDark, context).copyWith(
            color: selected
                ? AlmaColors.background(isDark)
                : AlmaColors.textPrimary(isDark),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // =====================
  // PRIMARY BUTTON
  // =====================
  Widget _primaryButton({
    required bool isDark,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AlmaColors.textPrimary(isDark),
          foregroundColor: AlmaColors.background(isDark),
          disabledBackgroundColor:
              AlmaColors.textMuted(isDark).withValues(alpha: .3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AlmaRadius.full),
          ),
        ),
        child: Text(
          label,
          style: AlmaTypography.labelLarge(isDark, context).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: onPressed == null
                ? AlmaColors.textMuted(isDark)
                : AlmaColors.background(isDark),
          ),
        ),
      ),
    );
  }

  // =====================
  // STEP 1 — INTRO
  // =====================
  Widget _introStep(bool isDark) {
    return _stepShell(
      isDark: isDark,
      icon: Icons.spa_outlined,
      question: 'Estás a punto de empezar algo importante.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Alma es tu espacio para escribir, procesar y sanar. Estas preguntas nos ayudan a personalizarlo para ti.',
            style: AlmaTypography.bodyLarge(isDark, context).copyWith(
              color: AlmaColors.textSecondary(isDark),
              height: 1.6,
            ),
          ),
        ],
      ),
      action: _primaryButton(
        isDark: isDark,
        label: 'Comenzar',
        onPressed: _next,
      ),
    );
  }

  // =====================
  // STEP 2 — NOMBRE
  // =====================
  Widget _nameStep(bool isDark) {
    return _stepShell(
      isDark: isDark,
      icon: Icons.person_outline,
      question: '¿Cómo te llamas?',
      body: Column(
        children: [
          TextField(
            cursorColor: AlmaColors.textPrimary(isDark),
            controller: _nameController,
            style: AlmaTypography.bodyLarge(isDark, context),
            decoration: InputDecoration(
              hintText: 'Tu nombre',
              hintStyle: AlmaTypography.bodyLarge(isDark, context).copyWith(
                color: AlmaColors.textMuted(isDark),
              ),
              filled: true,
              fillColor: AlmaColors.surfaceVariant(isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AlmaRadius.input),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AlmaRadius.input),
                borderSide: BorderSide(
                  color: AlmaColors.textPrimary(isDark),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
      action: _primaryButton(
        isDark: isDark,
        label: 'Continuar',
        onPressed: (_name?.isNotEmpty == true) ? _next : null,
      ),
    );
  }

  // =====================
  // STEP 3 — EMOCIÓN
  // =====================
  Widget _emotionStep(bool isDark) {
    // Onboarding screen — corregir los values:
    final options = [
      ('abrumado', 'Me siento con claridad y dirección'),
      ('nublado', 'Tengo días buenos y días difíciles'),
      ('agotado', 'Me cuesta ver con claridad'),
      ('inspirado', 'Estoy en un momento muy difícil'),  //todo ajustar las labels
    ];

    return _stepShell(
      isDark: isDark,
      icon: Icons.cloud_outlined,
      question: '¿Cómo describirías tu estado emocional hoy?',
      body: ListView.separated(
        itemCount: options.length,
        separatorBuilder: (_, _) =>
            SizedBox(height: AlmaSpacing.r(context, AlmaSpacing.xs)),
        itemBuilder: (_, i) => _optionTile(
          isDark: isDark,
          label: options[i].$2,
          selected: _emotionalState == options[i].$1,
          onTap: () {
            setState(() => _emotionalState = options[i].$1);
            Future.delayed(const Duration(milliseconds: 250), _next);
          },
        ),
      ),
    );
  }

  // =====================
  // STEP 4 — DOLOR
  // =====================
  Widget _painStep(bool isDark) {
    // Onboarding screen — corregir los values:
        final options = [
          ('estres', 'Llevo una máscara en la vida diaria'),
          ('vacio', 'Temo enfrentarme a mis emociones'),
          ('confusion', 'Me siento inseguro en mi presente'),
          ('cansancio', 'Evito pensar en mi pasado'),
        ];

    return _stepShell(
      isDark: isDark,
      icon: Icons.favorite_border_outlined,
      question: '¿Qué afirmación resuena más contigo?',
      body: ListView.separated(
        itemCount: options.length,
        separatorBuilder: (_, _) =>
            SizedBox(height: AlmaSpacing.r(context, AlmaSpacing.xs)),
        itemBuilder: (_, i) => _optionTile(
          isDark: isDark,
          label: options[i].$2,
          selected: _painPoint == options[i].$1,
          onTap: () {
            setState(() => _painPoint = options[i].$1);
            Future.delayed(const Duration(milliseconds: 250), _next);
          },
        ),
      ),
    );
  }

  // =====================
  // STEP 5 — META
  // =====================
  Widget _goalStep(bool isDark) {
    final options = [
      ('paz', 'Encontrar paz y calma interior'),
      ('orden', 'Ordenar mis pensamientos y emociones'),
      ('acompañamiento', 'Sentirme menos solo en lo que vivo'),
      ('crecimiento', 'Crecer y conocerme mejor'),
    ];

    final canFinish = _emotionalState != null &&
        _painPoint != null &&
        _hopefulGoal != null;

    return _stepShell(
      isDark: isDark,
      icon: Icons.star_border_outlined,
      question: '¿Qué buscas encontrar aquí?',
      body: ListView.separated(
        itemCount: options.length,
        separatorBuilder: (_, _) =>
            SizedBox(height: AlmaSpacing.r(context, AlmaSpacing.xs)),
        itemBuilder: (_, i) => _optionTile(
          isDark: isDark,
          label: options[i].$2,
          selected: _hopefulGoal == options[i].$1,
          onTap: () => setState(() => _hopefulGoal = options[i].$1),
        ),
      ),
      action: _primaryButton(
        isDark: isDark,
        label: 'Acceder',
        onPressed: canFinish ? _finish : null,
      ),
    );
  }

  String _deriveArchetype(String? emotionalState, String? painPoint) {
  if (emotionalState == 'abrumado' || painPoint == 'estres')    return 'mask';
  if (emotionalState == 'nublado'  || painPoint == 'confusion') return 'moon';
  if (emotionalState == 'agotado'  || painPoint == 'cansancio') return 'shadow';
  return 'mirror'; // fallback
}
}
