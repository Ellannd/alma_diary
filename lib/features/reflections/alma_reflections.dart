import 'package:flutter/material.dart';
import "package:alma_diary/services/supabase_service.dart";
import "package:alma_diary/data/aes_encryption.dart";
import 'package:alma_diary/features/reflections/alma_reflection_card.dart';
import "package:alma_diary/core/logging/log_service.dart";

class AlmaReflectionsScreen extends StatefulWidget {
  final String passphrase;

  const AlmaReflectionsScreen({super.key, required this.passphrase});

  @override
  State<AlmaReflectionsScreen> createState() => _AlmaReflectionsScreenState();
}

class _AlmaReflectionsScreenState extends State<AlmaReflectionsScreen> {
  List<Map<String, dynamic>> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _loading = true);

    try {
      final userId = SupabaseService.instance.client.auth.currentUser?.id;

      if (userId == null) {
        setState(() {
          _entries = [];
          _loading = false;
        });
        return;
      }

      final response = await SupabaseService.instance.client
          .from('journal_entries')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        _entries = List<Map<String, dynamic>>.from(response);
        _loading = false;
      });
    } catch (e, st) {
      LogService.instance.error(
        'Error cargando entradas',
        error: e,
        stackTrace: st,
      );
      setState(() {
        _entries = [];
        _loading = false;
      });
    }
  }

  String _decryptContent(String encrypted) {
    if (encrypted.isEmpty) return 'Sin contenido';

    try {
      return AESEncryption.decryptText(encrypted, widget.passphrase);
    } catch (e) {
      return 'Error al descifrar contenido';
    }
  }

  void _showEntryDetail(Map<String, dynamic> entry) {
    final encrypted = entry['content_encrypted'] ?? '';
    final decrypted = _decryptContent(encrypted);

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
                    decrypted,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                if ((entry['reflexion'] ?? '').toString().isNotEmpty) ...[
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
                    reflection: entry['reflexion'],
                    archetype: entry['archetype'] ?? 'The Mirror',
                    sentiment: entry['sentiment'] ?? 'neutral',
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

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
          ? Center(
              child: Text(
                'No hay entradas de diario aún.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadEntries,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _entries.length,
                itemBuilder: (context, i) {
                  final entry = _entries[i];

                  final encrypted = entry['content_encrypted'] ?? '';

                  final content = _decryptContent(encrypted);

                  final rawDate = entry['created_at'];
                  final date =
                      DateTime.tryParse(rawDate?.toString() ?? '') ??
                      DateTime.now();

                  final sentiment = (entry['sentiment'] ?? '').toString();

                  final archetype = (entry['archetype'] ?? '').toString();

                  return Card(
                    color: Theme.of(context).cardColor,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(20),

                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withValues(
                          alpha: 0.3,
                        ),
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      title: Text(
                        '${date.day.toString().padLeft(2, '0')}/'
                        '${date.month.toString().padLeft(2, '0')} '
                        '${date.hour.toString().padLeft(2, '0')}:'
                        '${date.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          if (sentiment.isNotEmpty)
                            Chip(
                              label: Text(sentiment),
                              backgroundColor: Colors.blue.withValues(
                                alpha: 0.2,
                              ),
                              labelStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),

                          if (archetype.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Chip(
                                label: Text(archetype),
                                backgroundColor: Theme.of(context).colorScheme.secondary.withValues(
                                  alpha: 0.4,
                                ),
                                labelStyle: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ),

                          const SizedBox(height: 8),

                          Text(
                            content.length > 120
                                ? '${content.substring(0, 120)}...'
                                : content,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: .7),
                            ),
                          ),
                        ],
                      ),

                      trailing: IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () => _showEntryDetail(entry),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
