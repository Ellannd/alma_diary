import 'package:flutter/material.dart';

class AuthFooter extends StatelessWidget {
  const AuthFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Al continuar aceptas Términos y Privacidad',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 11,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
      ),
    );
  }
}