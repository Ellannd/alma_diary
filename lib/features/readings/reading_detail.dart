import 'package:flutter/material.dart';
import 'package:alma_diary/features/readings/engine/readings_engine.dart';
import "package:alma_diary/features/readings/controller/reading_controller.dart";
import "package:alma_diary/features/readings/data/reading_repository.dart";


class ReadingDetailScreen extends StatelessWidget {
  final dynamic reading;

  const ReadingDetailScreen({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    String title;
    String content;
    String author;
    String quote = '';
    String tag = '';
    String level = '';

    if (reading is ReadingRecommendation) {
      final rec = reading;
      title = rec.titulo ?? 'Sin título';
      content = rec.porqueLeerla;
      author = rec.autor ?? 'Anónimo';
      quote = ReadingController(ReadingRepository()).getFormattedText(rec.fragmento);
      tag = rec.tag ?? '';
      level = rec.nivelDeConsciencia ?? '';
    } else if (reading is Map<String, String>) {
      final map = reading;
      title = map['title'] ?? 'Lectura Personalizada';
      content = map['content'] ?? '';
      author = map['author'] ?? 'Anónimo';
      quote = map['quote'] ?? '';
    } else {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).cardColor,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        body: Center(
          child: Text(
            'Lectura no válida',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      );
    }
    final normalized = content
        .replaceAll('\\n', '\n') // 🔥 clave para Supabase
        .trim();
    final paragraphs = normalized.split(
      '\n\n',
    ); // dividir en párrafos por doble salto de línea

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tag.isNotEmpty || level.isNotEmpty)
              Row(
                children: [
                  if (tag.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  if (tag.isNotEmpty && level.isNotEmpty)
                    const SizedBox(width: 10),
                  if (level.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: .6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Nivel: $level',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: .6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            if (tag.isNotEmpty || level.isNotEmpty) const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu_book, color: Theme.of(context).colorScheme.onSurface, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          author,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: paragraphs.map((p) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Text(
                          p.trim(),
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.7,
                            fontFamilyFallback: [
                              'Georgia',
                              'Times New Roman',
                              'serif',
                            ],
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            if (quote.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.format_quote,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Cápsula de sabiduría',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '"$quote"',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_stories,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  size: 32,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
