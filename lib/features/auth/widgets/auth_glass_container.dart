import 'dart:ui';
import 'package:flutter/material.dart';

class AuthGlassContainer extends StatelessWidget {
  final Widget child;

  const AuthGlassContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.08),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}