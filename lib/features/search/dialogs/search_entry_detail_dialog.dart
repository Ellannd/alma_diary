import 'package:flutter/material.dart';
import 'package:alma_diary/data/aes_encryption.dart';
import 'package:alma_diary/features/reflections/alma_reflection_card.dart';

class SearchEntryDetailDialog {
  static void show({
    required BuildContext context,
    required Map<String, dynamic> entry,
    required String passphrase,
  }) {
    final encrypted = (entry['content_encrypted'] ?? '').toString();

    final decrypted = encrypted.isEmpty
        ? 'Contenido no disponible'
        : AESEncryption.decryptText(encrypted, passphrase);

    final reflection = entry['reflection'];
    final archetype = entry['archetype'] ?? 'The Mirror';
    final sentiment = entry['sentiment'] ?? 'neutral';

    DateTime date;
    try {
      date = DateTime.parse(
        (entry['created_at'] ?? DateTime.now().toIso8601String())
            .toString(),
      ).toLocal();
    } catch (_) {
      date = DateTime.now();
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Resultado ${date.day.toString().padLeft(2, '0')}/'
                      '${date.month.toString().padLeft(2, '0')}/'
                      '${date.year}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// ENTRY CONTENT
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    decrypted,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// REFLECTION
                if (reflection != null &&
                    reflection.toString().isNotEmpty) ...[
                  Text(
                    'Reflexión de Alma',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  AlmaReflectionCard(
                    reflection: reflection,
                    archetype: archetype,
                    sentiment: sentiment,
                  ),
                ] else
                  Text(
                    'No hay reflexión disponible para esta entrada.',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),

                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}