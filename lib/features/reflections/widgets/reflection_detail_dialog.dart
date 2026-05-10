import 'package:flutter/material.dart';

import 'package:alma_diary/features/reflections/widgets/reflection_card.dart';
import 'package:alma_diary/features/reflections/widgets/reflection_tags.dart';

Future<void> showReflectionDetail({
  required BuildContext context,
  required Map<String, dynamic> entry,
}) {
  final content =
      entry['content_decrypted'] ??
      entry['content_encrypted'] ??
      'Sin contenido';

  final reflection =
      entry['analysis_decrypted'] ??
      entry['analysis_encrypted'] ??
      '';

  final archetype = entry['archetype'] ?? 'The Mirror';
  final sentiment = entry['sentiment'] ?? 'neutral';

  final rawDate = entry['created_at'];

  final date =
      DateTime.tryParse(rawDate?.toString() ?? '') ??
      DateTime.now();

  return showDialog(
    context: context,
    builder: (ctx) {
      return Dialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        insetPadding: const EdgeInsets.all(16),

        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),

          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      'Entrada '
                      '${date.day.toString().padLeft(2, '0')}/'
                      '${date.month.toString().padLeft(2, '0')}/'
                      '${date.year}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface,
                      ),
                    ),

                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context)
                            .iconTheme
                            .color,
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // TAGS
                ReflectionTags(
                  archetype: archetype,
                  sentiment: sentiment,
                ),

                const SizedBox(height: 20),

                // ENTRY CONTENT
                Container(
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Text(
                    content,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // REFLECTION
                if (reflection.isNotEmpty) ...[
                  Text(
                    'Reflexión de Alma',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  ReflectionCard(
                    reflection: reflection,
                    archetype: archetype,
                    sentiment: sentiment,
                  ),
                ] else
                  Text(
                    'No hay reflexión disponible.',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),

                const SizedBox(height: 24),

                Align(
                  alignment: Alignment.centerRight,

                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },

                    icon: const Icon(
                      Icons.arrow_forward,
                      size: 18,
                    ),

                    label: const Text('Continuar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}