import 'package:flutter/material.dart';

class AlmaOnboarding extends StatelessWidget {
  final VoidCallback onFinish;

  const AlmaOnboarding({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite, size: 80, color: color.primary),
              const SizedBox(height: 24),
              Text(
                'Escribe, sana, vive',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color.onSurface,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onFinish,
                child: const Text('Comenzar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}