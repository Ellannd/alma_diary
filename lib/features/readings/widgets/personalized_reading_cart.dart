import 'package:flutter/material.dart';

class PersonalizedReadingCard extends StatelessWidget {
  final Map<String, String> data;
  final VoidCallback onSave;

  const PersonalizedReadingCard({
    super.key,
    required this.data,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['title'] ?? '',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            Text(data['content'] ?? ''),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: onSave,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}