import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alma_diary/ai/engines/readings_engine.dart';
import 'reading_detail.dart';
import 'controller/reading_controller.dart';
import 'data/reading_repository.dart';
import "package:alma_diary/core/logging/log_service.dart";

class AlmaReadingsScreen extends StatefulWidget {
  final String passphrase;
  const AlmaReadingsScreen({
    super.key,
    required this.passphrase,
    required String userId,
  });

  @override
  State<AlmaReadingsScreen> createState() => _AlmaReadingsScreenState();
}

class _AlmaReadingsScreenState extends State<AlmaReadingsScreen> {
  late ReadingController _controller;
  late ReadingsEngine _engine;
  List<ReadingRecommendation> _recs = [];
  bool _loading = true;
  final Set<String> _helped = {};
  Map<String, String>? _personalizedReading;
  bool _generatingPersonalized = false;
  String? _userId;

  Future<void> _generatePersonalizedReading() async {
    if (_generatingPersonalized) return;

    LogService.instance.info('Iniciando generación de lectura personalizada');
    setState(() => _generatingPersonalized = true);
    try {
      final data = await _engine.generatePersonalizedReading();
      if (!mounted) return;
      setState(() => _personalizedReading = data);
      LogService.instance.info('Lectura personalizada generada exitosamente');
    } catch (e, st) {
      LogService.instance.error(
        'Error generando lectura personalizada',
        error: e,
        stackTrace: st,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generando lectura: $e')));
    } finally {
      if (mounted) {
        setState(() => _generatingPersonalized = false);
      }
    }
  }

  Future<void> _savePersonalizedReading() async {
    if (_personalizedReading == null) return;
    
    // Generate a temporary ID for personalized reading
    final readingId = 'personalized_${DateTime.now().millisecondsSinceEpoch}';
    
    try {
      await _controller.toggleSave(readingId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Guardado en tu biblioteca!')));
      setState(() => _personalizedReading = null);
    } catch (e, st) {
      LogService.instance.error(
        'Error guardando lectura personalizada',
        error: e,
        stackTrace: st,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error guardando lectura: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _engine = ReadingsEngine(widget.passphrase);
    _controller = ReadingController(ReadingRepository());
    
    // Get userId from Supabase auth
    _userId = Supabase.instance.client.auth.currentUser?.id;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  Future<void> _init() async {
    if (_userId == null) {
      LogService.instance.error('User not authenticated');
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }

    _controller.setUser(_userId!);

    try {
      await _controller.load();
      
      if (!mounted) return;

      // Convert to ReadingRecommendation format for UI compatibility
      _recs = _controller.readings.map((item) {
        final tagsRaw = item['tags'];
        final List<String> tags = tagsRaw is List
            ? List<String>.from(tagsRaw)
            : (tagsRaw is String
                ? tagsRaw.split(',').map((e) => e.trim()).toList()
                : []);

        return ReadingRecommendation(
          idLectura: (item['id'] ?? '').toString(),
          titulo: (item['title'] ?? 'Sin título').toString(),
          autor: (item['author'] ?? 'Desconocido').toString(),
          tag: tags.isNotEmpty ? tags.first : 'general',
          porqueLeerla: 'Lectura basada en psicología aplicada y análisis emocional.',
          nivelDeConsciencia: (item['category'] ?? 'básico').toString(),
          fragmento: (item['content'] ?? '').toString(),
        );
      }).toList();

      setState(() => _loading = false);
    } catch (e, st) {
      LogService.instance.error(
        'Error cargando lecturas',
        error: e,
        stackTrace: st,
      );

      if (!mounted) return;

      setState(() {
        _recs = [];
        _loading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando lecturas: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lecturas Recomendadas')),
      body: Column(
        children: [
          if (_personalizedReading != null) ...[
            Container(
              margin: const EdgeInsets.all(16),
              child: PersonalizedReadingCard(
                data: _personalizedReading!,
                onSave: _savePersonalizedReading,
              ),
            ),
            const Divider(height: 0),
          ],
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
: _recs.isEmpty
                ? const Center(child: Text('No hay recomendaciones aún.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: _recs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 24),
                    itemBuilder: (context, i) => _ReadingCard(
                      rec: _recs[i],
                      saved: _controller.isSaved(_recs[i].idLectura),
                      helped: _helped.contains(_recs[i].idLectura),
                      onSave: () async {
                        await _controller.toggleSave(_recs[i].idLectura);
                        setState(() {});
                      },
                      onHelped: () =>
                          setState(() => _helped.add(_recs[i].idLectura)),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generatingPersonalized
            ? null
            : _generatePersonalizedReading,
        label: Text(
          _generatingPersonalized
              ? 'Generando...'
              : 'Nueva Lectura Personalizada',
        ),
        icon: _generatingPersonalized
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.auto_awesome),
      ),
    );
  }
}

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
    final title = data['title'] ?? 'Lectura Personalizada';
    final content = data['content'] ?? '';
    final author = data['author'] ?? 'Anónimo';
    final quote = data['quote'] ?? '';

    return Card(
      color: const Color(0xFFF5F5DC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.brown.shade200),
      ),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamilyFallback: ['Georgia', 'Times New Roman', 'serif'],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                fontFamilyFallback: ['Georgia', 'Times New Roman', 'serif'],
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.brown.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        author,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamilyFallback: [
                            'Georgia',
                            'Times New Roman',
                            'serif',
                          ],
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.format_quote, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), size: 24),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    quote,
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      fontFamilyFallback: [
                        'Georgia',
                        'Times New Roman',
                        'serif',
                      ],
                      color: Colors.brown.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.library_add),
                label: const Text('Guardar en mi Biblioteca'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadingCard extends StatelessWidget {
  final ReadingRecommendation rec;
  final bool saved;
  final bool helped;
  final VoidCallback onSave;
  final VoidCallback onHelped;

  const _ReadingCard({
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
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ReadingDetailScreen(reading: rec)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Card(
          color: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.menu_book,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec.titulo,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rec.autor,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        rec.tag,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  rec.porqueLeerla,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8)),
                    const SizedBox(width: 6),
                    Text(
                      'Nivel: ${rec.nivelDeConsciencia}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.format_quote,
                        color: Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.6),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '"${ReadingController(ReadingRepository()).getFormattedText(rec.fragmento)}"',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: saved ? null : onSave,
                      icon: Icon(
                        saved
                            ? Icons.bookmark_added
                            : Icons.bookmark_add_outlined,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
                        size: 20,
                      ),
                      label: Text(
                        saved ? 'Guardado' : 'Guardar',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: helped ? null : onHelped,
                      icon: Icon(
                        helped ? Icons.favorite : Icons.favorite_border,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha:  0.9 ),
                        size: 20,
                      ),
                      label: Text(
                        helped ? 'Te ayudó' : 'Me ayudó',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
