import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/challenge_card.dart';
import '../widgets/challenge_empty_state.dart';
import 'package:alma_diary/state/challenges/challenge_controller.dart';
import 'package:alma_diary/state/challenges/challenge_provider.dart';
import "package:alma_diary/state/challenges/challenge_state.dart";

class ChallengeScreen extends ConsumerWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(challengeControllerProvider);
    final controller = ref.read(challengeControllerProvider.notifier);

    // INIT SAFE (solo una vez cuando hay user)
    if (state.userId != null && state.challenges.isEmpty && !state.isLoading) {
      Future.microtask(() {
        controller.loadChallenges();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Desafíos'),
      ),
      body: _buildBody(state, controller),
    );
  }

  Widget _buildBody(ChallengeState state, ChallengeController controller) {
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
      padding: const EdgeInsets.all(16),
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
}