import 'package:flutter/material.dart';

import 'package:alma_diary/features/journal/alma_journal.dart';


class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.edit_note_outlined,
                size: 120,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(height: 32),
              Text(
                'Nueva entrada',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              Text(
                'La única salida es a través de ello.\nAlma te acompañará en el análisis.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AlmaJournal()),
                    ).then((_) {
                      // Refresh parent or global state if needed
                    });
                  },
                  icon: const Icon(Icons.add, size: 28),
                  label: Text('Escribir Diario', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home',
                  (route) => false,
                );
              },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

