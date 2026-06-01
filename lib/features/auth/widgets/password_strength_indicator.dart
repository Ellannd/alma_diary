// auth/widgets/password_strength_indicator.dart

import 'package:flutter/material.dart';

enum PasswordStrength { empty, weak, medium, strong }

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  static PasswordStrength evaluate(String password) {
    if (password.isEmpty) return PasswordStrength.empty;
    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    return switch (score) {
      0 || 1 => PasswordStrength.weak,
      2      => PasswordStrength.medium,
      _      => PasswordStrength.strong,
    };
  }

  @override
  Widget build(BuildContext context) {
    final strength = evaluate(password);
    if (strength == PasswordStrength.empty) return const SizedBox.shrink();

    final (label, color, bars) = switch (strength) {
      PasswordStrength.weak   => ('Débil',   Colors.redAccent,     1),
      PasswordStrength.medium => ('Media',   Colors.orange,        2),
      PasswordStrength.strong => ('Fuerte',  Colors.green.shade400, 3),
      PasswordStrength.empty  => ('',        Colors.transparent,   0),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: List.generate(3, (i) {
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 4),
                height: 3,
                decoration: BoxDecoration(
                  color: i < bars ? color : Colors.grey.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            label,
            key: ValueKey(label),
            style: TextStyle(fontSize: 12, color: color),
          ),
        ),
      ],
    );
  }
}