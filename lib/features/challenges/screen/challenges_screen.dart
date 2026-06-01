import 'package:alma_diary/design_system/components/feedback/alma_loader.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/state/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/challenge_card.dart';
import '../widgets/challenge_empty_state.dart';
import 'package:alma_diary/state/challenges/challenge_controller.dart';
import "package:alma_diary/state/challenges/challenge_state.dart";

class ChallengesPage extends ConsumerStatefulWidget {
  const ChallengesPage({super.key});

  @override
  ConsumerState<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends ConsumerState<ChallengesPage> {

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId != null) {
      ref.read(challengeControllerProvider.notifier).setUserId(userId);
    }

    ref.listen(currentUserProvider, (prev, next) {
      final prevUser = prev?.id;
      final nextUser = next?.id;
      if (nextUser != null && prevUser != nextUser) {
        ref.read(challengeControllerProvider.notifier).setUserId(nextUser);
      }
    });
  });
}

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(challengeControllerProvider);
    final controller = ref.read(challengeControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Desafíos')),
      body: _buildBody(context, state, controller),
    );
  }

   Widget _buildBody(BuildContext context, ChallengeState state, ChallengeController controller) {
    // ======================
    // LOADING
    // ======================
    if (state.isLoading && state.challenges.isEmpty) {
      return const Center(child: AlmaLoader());
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
}
 

