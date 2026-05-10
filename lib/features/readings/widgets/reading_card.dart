import 'package:flutter/material.dart';

class ReadingCard extends StatelessWidget {
  final dynamic rec;
  final bool saved;
  final bool helped;
  final VoidCallback onSave;
  final VoidCallback onHelped;

  const ReadingCard({
    super.key,
    required this.rec,
    required this.saved,
    required this.helped,
    required this.onSave,
    required this.onHelped,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/reading-detail',
          arguments: rec,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rec['title'] ?? '',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 8),

            Text(rec['author'] ?? ''),

            const SizedBox(height: 12),

            Text(rec['summary'] ?? ''),

            const SizedBox(height: 12),

            Row(
              children: [
                TextButton(
                  onPressed: onSave,
                  child: Text(saved ? 'Guardado' : 'Guardar'),
                ),

                const SizedBox(width: 8),

                TextButton(
                  onPressed: helped ? null : onHelped,
                  child: Text(helped ? 'Ayudó' : 'Me ayudó'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}