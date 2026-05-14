import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alma_diary/features/challenges/engine/challenges_engine_v2.dart';
import 'package:alma_diary/features/dashboard/old/alma_theme_old.dart';
import 'challenge_controller_old.dart';

class AlmaChallengesScreen extends StatefulWidget {
  final String passphrase;

  const AlmaChallengesScreen({super.key, required this.passphrase});

  @override
  State<AlmaChallengesScreen> createState() => _AlmaChallengesScreenState();
}

class _AlmaChallengesScreenState extends State<AlmaChallengesScreen> {
  late ChallengeController _controller;
  bool _initialized = false;

  //TODO: Quitar todas las referencias a SUPABASE en UI. Crear un AuthService o moverlo al controller
  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    final userId = _userId;
    if (userId == null) return;

    _controller = ChallengeController();

    _controller.setUserId(userId);

    _controller.addListener(_onControllerUpdate);

    await _controller.loadChallenges();

    if (!mounted) return;

    setState(() {
      _initialized = true;
    });
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    if (_initialized) {
      _controller.removeListener(_onControllerUpdate);
      _controller.reset();
    }
    super.dispose();
  }

  void _onStartChallenge(String challengeId) async {
    await _controller.startChallenge(challengeId);
  }

  void _onUpdateProgress(String challengeId, int newProgress) async {
    await _controller.updateProgress(challengeId, newProgress);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized || _userId == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Desafíos'),
          backgroundColor: Theme.of(context).cardColor,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Get current state from controller (single source of truth)
    final challenges = _controller.challenges;
    final isLoading = _controller.isLoading;
    final error = _controller.error;

    // Show error if any
    if (error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
        _controller.clearError();
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Desafíos'),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: isLoading && challenges.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : challenges.isEmpty
              ? _buildEmptyState()
              : _buildChallengeList(challenges),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: AlmaTheme.accent.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay desafíos disponibles',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeList(List<Challenge> challenges) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        
        // Get state from controller (single source of truth)
        final progress = _controller.getProgress(challenge.id);
        final status = _controller.getStatus(challenge.id);
        final isActive = status == 'active';
        final isCompleted = status == 'completed';

        return _ChallengeCard(
          title: challenge.title,
          description: challenge.description,
          difficulty: challenge.difficulty,
          category: challenge.category,
          progress: progress,
          isActive: isActive,
          isCompleted: isCompleted,

          onStart: !isActive && !isCompleted
              ? () => _onStartChallenge(challenge.id)
              : null,

          onUpdateProgress:
              isActive && !isCompleted
                  ? (newProgress) => _onUpdateProgress(challenge.id, newProgress)
                  : null,
        );
      },
    );
  }
}

/// _ChallengeCard - Pure UI Component
/// 
/// Responsibilities:
/// - Display challenge card
/// - Handle user interactions
/// - No state, no business logic

class _ChallengeCard extends StatelessWidget {
  final String title;
  final String description;
  final int difficulty;
  final String category;
  final int progress;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback? onStart;
  final Function(int)? onUpdateProgress;

  const _ChallengeCard({
    required this.title,
    required this.description,
    required this.difficulty,
    required this.category,
    required this.progress,
    required this.isActive,
    required this.isCompleted,
    this.onStart,
    this.onUpdateProgress,
  });

  Widget _mini(BuildContext context, String text, VoidCallback onTap) {
    final accent = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: accent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (category.toLowerCase()) {
      case 'valentía':
        return Icons.shield_rounded;
      case 'disciplina':
        return Icons.fitness_center;
      case 'mindfulness':
        return Icons.self_improvement;
      case 'emocional':
        return Icons.favorite_rounded;
      default:
        return Icons.auto_awesome;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.20),
              blurRadius: 18,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.20),
                child: Icon(_getIcon(), color: accent, size: 20),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.80),
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                children: List.generate(
                  difficulty.clamp(1, 10),
                  (i) => const Icon(Icons.star, size: 14, color: Colors.amber),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // DESCRIPTION
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 14),

          // PROGRESS
          if (isActive || isCompleted) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress / 100,
                minHeight: 8,
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation(accent),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isCompleted ? 'Completado' : 'Progreso: $progress%',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.80),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // ACTION - START BUTTON
          if (!isActive && !isCompleted && onStart != null)
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Iniciar desafío'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),

          // ACTION - PROGRESS BUTTONS
          if (isActive && !isCompleted && onUpdateProgress != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _mini(context, '25%', () => onUpdateProgress!((progress + 25).clamp(0, 100))),
                _mini(context, '50%', () => onUpdateProgress!((progress + 50).clamp(0, 100))),
                _mini(context, '100%', () => onUpdateProgress!(100)),
              ],
            ),
        ],
      ),
    );
  }
}
