// lib/ai/chat/widgets/chat_typing_indicator.dart

import 'package:flutter/material.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';

class ChatTypingIndicator extends StatefulWidget {
  const ChatTypingIndicator({super.key});

  @override
  State<ChatTypingIndicator> createState() => _ChatTypingIndicatorState();
}

class _ChatTypingIndicatorState extends State<ChatTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AlmaSpacing.xs),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AlmaColors.textPrimary(isDark),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AlmaRadius.lg),
              topRight: Radius.circular(AlmaRadius.lg),
              bottomLeft: Radius.circular(AlmaRadius.xs),
              bottomRight: Radius.circular(AlmaRadius.lg),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (i) => _Dot(index: i, ctrl: _ctrl, isDark: isDark),
            ),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final int index;
  final AnimationController ctrl;
  final bool isDark;

  const _Dot({required this.index, required this.ctrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final delay = index * 0.2;

    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, _) {
        final t = ((ctrl.value - delay) % 1.0).clamp(0.0, 1.0);
        final bounce = (t < 0.5 ? t * 2 : (1 - t) * 2);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 7,
          height: 7 + (bounce * 4),
          decoration: BoxDecoration(
            color: AlmaColors.accent(
              isDark,
            ).withValues(alpha: .4 + bounce * 0.6),
            borderRadius: BorderRadius.circular(AlmaRadius.full),
          ),
        );
      },
    );
  }
}
