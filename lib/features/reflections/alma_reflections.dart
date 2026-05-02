import 'package:flutter/material.dart';
import 'package:alma_diary/features/reflections/alma_reflection_card.dart';
import 'package:alma_diary/features/reflections/controller/reflection_controller.dart';

class AlmaReflectionsScreen extends StatefulWidget {
  final String passphrase;

  const AlmaReflectionsScreen({super.key, required this.passphrase});

  @override
  State<AlmaReflectionsScreen> createState() => _AlmaReflectionsScreenState();
}

class _AlmaReflectionsScreenState extends State<AlmaReflectionsScreen> {
  late ReflectionController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = ReflectionController();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      await _controller.loadEntries();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() {});
    }
  }

  void _showEntryDetail(Map<String, dynamic> entry) {
    final content = entry['content_decrypted'] ?? entry['content_encrypted'] ?? 'Sin contenido';
    final reflection = entry['analysis_decrypted'] ?? entry['analysis_encrypted'] ?? '';
    final archetype = entry['archetype'] ?? 'The Mirror';
    final sentiment = entry['sentiment'] ?? 'neutral';
    
    final rawDate = entry['created_at'];
    final date = DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Entrada ${date.day.toString().padLeft(2, '0')}/'
                      '${date.month.toString().padLeft(2, '0')}/'
                      '${date.year}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    content,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                if (reflection.isNotEmpty) ...[
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
                  const Text(
                    'No hay reflexión disponible para esta entrada.',
                    style: TextStyle(color: Colors.white54),
                  ),

                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Continuar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reflexiones'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadEntries),
        ],
      ),

body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _controller.entries.isEmpty
          ? Center(
              child: Text(
                _controller.error ?? 'No hay entradas de diario aún.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface, 
                  fontSize: 16,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadEntries,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _controller.entries.length,
                itemBuilder: (context, i) {
                  final entry = _controller.entries[i];

                  final content = entry['content_decrypted'] ?? entry['content_encrypted'] ?? '';
                  final archetype = entry['archetype'] ?? '';
                  final sentiment = entry['sentiment'] ?? '';

                  final rawDate = entry['created_at'];
                  final date = DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now();

                  return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                            Theme.of(context).cardColor,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => _showEntryDetail(entry),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 📅 HEADER FECHA
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${date.day.toString().padLeft(2, '0')}/'
                                      '${date.month.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 18,
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // 🧠 TAGS (archetype + sentiment)
                              if (archetype.isNotEmpty || sentiment.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    if (archetype.isNotEmpty)
                                      _buildTag(context, archetype, Icons.psychology),

                                    if (sentiment.isNotEmpty)
                                      _buildTag(context, sentiment, Icons.favorite),
                                  ],
                                ),

                              const SizedBox(height: 14),

                              // 💬 CONTENIDO
                              Text(
                                content.length > 140
                                    ? '${content.substring(0, 140)}...'
                                    : content,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.8),
                                  fontSize: 14.5,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // ➜ INDICADOR DE ACCIÓN
                              Align(
                                alignment: Alignment.centerRight,
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                },
              ),
            ),
    );
  }

  Widget _buildTag(BuildContext context, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

}
