import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:flutter/material.dart';
import 'challenge_action_button.dart';

class ChallengeActionStrip extends StatelessWidget {
  final int progress;
  final Function(int)? onUpdateProgress;

  const ChallengeActionStrip({
    super.key,
    required this.progress,
    this.onUpdateProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ChallengeActionButton(
          text: '25%',
          onTap: () =>
              onUpdateProgress?.call((progress + 25).clamp(0, 100)),
        ),
        SizedBox(width: AlmaSpacing.r(context, 60)),
        ChallengeActionButton(
          text: '50%',
          onTap: () =>
              onUpdateProgress?.call((progress + 50).clamp(0, 100)),
        ),
        SizedBox(width: AlmaSpacing.r(context, 60)),
        ChallengeActionButton(
          text: '100%',
          onTap: () => onUpdateProgress?.call(100),
        ),
      ],
    );
  }
}