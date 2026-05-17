import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/challenge_card.dart';
import '../widgets/challenge_empty_state.dart';
import 'package:alma_diary/state/challenges/challenge_controller.dart';
import 'package:alma_diary/state/challenges/challenge_provider.dart';
import "package:alma_diary/state/challenges/challenge_state.dart";
import "package:alma_diary/state/auth/auth_controller.dart";

class ChallengesPage extends ConsumerStatefulWidget {
  const ChallengesPage({super.key});

  @override
  ConsumerState<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends ConsumerState<ChallengesPage> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userId = ref
          .read(authControllerProvider)
          .asData?.value.user?.id;

      if (userId == null) return;

      final controller = ref.read(challengeControllerProvider.notifier);
      controller.setUserId(userId);
      controller.loadChallenges();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(challengeControllerProvider);
    final controller = ref.read(challengeControllerProvider.notifier);

    // Por si el usuario cambia en caliente
    ref.listen(authControllerProvider, (prev, next) {
      final prevUser = prev?.asData?.value.user?.id;
      final nextUser = next.asData?.value.user?.id;

      if (nextUser != null && prevUser != nextUser) {
        controller.setUserId(nextUser);
        controller.loadChallenges();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Desafíos')),
      body: _buildBody(context, state, controller),
    );
  }
}
  Widget _buildBody(BuildContext context, ChallengeState state, ChallengeController controller) {
    // ======================
    // LOADING
    // ======================
    if (state.isLoading && state.challenges.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // ======================
    // ERROR
    // ======================
    if (state.error != null) {
      return Center(
        child: Text(
          state.error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    // ======================
    // EMPTY
    // ======================
    if (state.challenges.isEmpty) {
      return const ChallengeEmptyState();
    }

    // ======================
    // LIST
    // ======================
    return ListView.builder(
      padding: EdgeInsets.all(AlmaSpacing.r(context, AlmaSpacing.lg)),
      itemCount: state.challenges.length,
      itemBuilder: (context, index) {
        final challenge = state.challenges[index];

        final progress =
            state.progressByChallenge[challenge.id] ?? 0;

        final status =
            state.statusByChallenge[challenge.id] ?? 'idle';

        final isActive = status == 'active';
        final isCompleted = status == 'completed';

        return ChallengeCard(
          title: challenge.title,
          description: challenge.description,
          category: challenge.category,
          difficulty: challenge.difficulty,
          progress: progress,
          isActive: isActive,
          isCompleted: isCompleted,

          onStart: (!isActive && !isCompleted)
              ? () => controller.startChallenge(challenge.id)
              : null,

          onUpdateProgress: (isActive && !isCompleted)
              ? (value) =>
                  controller.updateProgress(challenge.id, value)
              : null,
        );
      },
    );
  }
