import 'package:flutter/material.dart';
import 'package:alma_diary/features/reflections/alma_reflection_card.dart';
import 'package:alma_diary/features/reflections/controller/reflection_controller.dart';

class EntryReflectionDetail extends StatefulWidget {
  final String entryId;
  final String passphrase;

  const EntryReflectionDetail({
    super.key,
    required this.entryId,
    required this.passphrase,
  });

  @override
  State<EntryReflectionDetail> createState() => _EntryReflectionDetailState();
}

class _EntryReflectionDetailState extends State<EntryReflectionDetail> {
  late ReflectionController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = ReflectionController();
    _loadEntry();
  }

  Future<void> _loadEntry() async {
    try {
      await _controller.loadEntry(widget.entryId);
      if (!mounted) return;
      setState(() {});
} catch (e) {
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reflexión')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_controller.selectedEntry == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reflexión')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _controller.error ?? 'Entrada no encontrada',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

    final entry = _controller.selectedEntry!;
    final content = entry['content_decrypted'] ?? 'Sin contenido';
    final reflection = entry['analysis_decrypted'] ?? '';
    final archetype = entry['archetype'] ?? 'The Mirror';
    final sentiment = entry['sentiment'] ?? 'neutral';
    
    final rawDate = entry['created_at'];
    final date = DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu Reflexión'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    content,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (reflection.isNotEmpty)
              AlmaReflectionCard(
                reflection: reflection,
                archetype: archetype,
                sentiment: sentiment,
              )
            else
              Text(
                'No hay reflexión disponible para esta entrada.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
          ],
        ),
      ),
    );
  }
}
