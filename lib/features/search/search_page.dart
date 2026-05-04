import 'package:flutter/material.dart';
import 'package:alma_diary/models/search_result.dart';
import 'package:alma_diary/services/supabase_service.dart';
import "package:alma_diary/features/ai/challenges/alma_challenges.dart";
import 'package:alma_diary/data/aes_encryption.dart';
import 'package:alma_diary/features/reflections/alma_reflection_card.dart';
import 'package:alma_diary/features/search/engine/search_engine.dart';

class SearchPage extends StatefulWidget {
  final String passphrase;

  const SearchPage({super.key, required this.passphrase});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _results = [];
  final SearchEngine _searchEngine = SearchEngine();
  String? _selectedArchetype;
  bool _loading = false;

  final List<String> _archetypes = [
    'The Mask',
    'The Mirror',
    'The Moon',
    'The Shadow',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    _performSearch(query);
  }

  Future<void> _performSearch(String query) async {
    if (mounted) setState(() => _loading = true);

    final client = SupabaseService.instance.client;
    final userId = client.auth.currentUser?.id;

    if (userId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    try {
      var queryBuilder = client
          .from('journal_entries')
          .select()
          .eq('user_id', userId);

      if (_selectedArchetype != null) {
        queryBuilder = queryBuilder.eq('archetype', _selectedArchetype!);
      }

      final results = await queryBuilder.order('created_at', ascending: false);

      final ranked = _searchEngine.rankResults(
        results: List<Map<String, dynamic>>.from(results),
        query: query,
        archetypeFilter: _selectedArchetype,
      );

      if (mounted) {
        setState(() {
          _results = ranked;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  void _selectArchetype(String archetype) {
    setState(() {
      _selectedArchetype = _selectedArchetype == archetype ? null : archetype;
    });
    _performSearch(_searchController.text.trim());
  }

  void _openJournal(Map<String, dynamic> entry) {
    _showEntryDetail(entry);
  }

  void _openReflection(Map<String, dynamic> entry) {
    _showEntryDetail(entry);
  }

  void _openChallenge(Map<String, dynamic> entry) {
    showChallengeDetail(entry);
  }

  void _showQuoteDetail(Map<String, dynamic> entry) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cita'),
        content: Text(entry['title'] ?? ''),
      ),
    );
  }

  void showChallengeDetail(Map<String, dynamic> entry) {
    final challenge = entry['challenges'] ?? entry;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HANDLE
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              /// TITLE
              Text(
                challenge['title'] ?? 'Desafío',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 10),

              /// CATEGORY
              if (challenge['category'] != null)
                Text(
                  challenge['category'].toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.2,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                  ),
                ),

              const SizedBox(height: 16),

              /// DESCRIPTION
              Text(
                challenge['description'] ?? '',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),

              const SizedBox(height: 20),

              /// ACTION
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);

                    // opcional: navegar a challenges screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AlmaChallengesScreen(
                          passphrase: 'alma_biometric_pass',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Ir al desafío'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _handleResultTap(SearchResult r) {
    switch (r.type) {
      case 'journal':
        _openJournal(r.entry);
        break;

      case 'reflection':
        _openReflection(r.entry);
        break;

      case 'challenge':
        _openChallenge(r.entry);
        break;

      case 'quote':
        _showQuoteDetail(r.entry);
        break;

      default:
        debugPrint('Unknown type: ${r.type}');
    }
  }

  void _showEntryDetail(Map<String, dynamic> entry) {
    /// 🔐 contenido seguro
    final encrypted = (entry['content_encrypted'] ?? '').toString();

    final decrypted = encrypted.isEmpty
        ? 'Contenido no disponible'
        : AESEncryption.decryptText(encrypted, widget.passphrase);

    /// fecha segura
    DateTime date;
    try {
      date = DateTime.parse(
        (entry['created_at'] ?? DateTime.now().toIso8601String()).toString(),
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
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Resultado ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
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
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (entry['reflection'] != null &&
                      entry['reflection'].toString().isNotEmpty) ...[
                    Text(
                      'Reflexión encontrada',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AlmaReflectionCard(
                      reflection: entry['reflection'],
                      archetype: entry['archetype'] ?? 'The Mirror',
                      sentiment: entry['sentiment'] ?? 'neutral',
                    ),
                  ],
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.search),
                      label: const Text('Buscar más'),
                    ),
                  ),
                ],
              ),
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
        title: const Text('Buscar Diarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _performSearch(_searchController.text.trim()),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por sentimiento, arquetipo o fecha...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                if (_loading) ...[
                  const SizedBox(width: 16),
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _archetypes.length,
              itemBuilder: (ctx, i) {
                final arch = _archetypes[i];
                final selected = _selectedArchetype == arch;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(arch),
                    selected: selected,
                    onSelected: (_) => _selectArchetype(arch),
                    selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 
                      selected ? 0.3 : 0.1,
                    ),
                    labelStyle: TextStyle(
                    color: selected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: .3),
                  ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay resultados',
                          style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                      fontSize: 18,
                    )
                    ),
                        Text(
                          'Prueba con palabras clave, emociones o temas',
                          style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.4),
                      )
                    ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () =>
                        _performSearch(_searchController.text.trim()),

                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _results.length,

                      itemBuilder: (ctx, i) {
                        final item = _results[i];
                        final result = _results[i];

                        // 🎨 color por tipo
                        Color color;
                        IconData icon;

                        switch (item.type) {
                          case 'journal':
                            color = Colors.blue;
                            icon = Icons.book;
                            break;
                          case 'reflection':
                            color = Colors.purple;
                            icon = Icons.psychology;
                            break;
                          case 'challenge':
                            color = Colors.orange;
                            icon = Icons.emoji_events;
                            break;
                          case 'quote':
                            color = Colors.green;
                            icon = Icons.format_quote;
                            break;
                          default:
                            color = Colors.grey;
                            icon = Icons.search;
                        }

                        return Card(
                          color: Theme.of(context).cardColor,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),

                          child: ListTile(
                            onTap: () => _handleResultTap(result),
                            contentPadding: const EdgeInsets.all(16),

                            leading: CircleAvatar(
                              backgroundColor: color.withValues(alpha: .2),
                              child: Icon(icon, color: color),
                            ),

                            title: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),

                            subtitle: Text(
                              item.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                                height: 1.3,
                              ),
                            ),

                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item.type.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: color.withValues(alpha: .8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: Colors.white38,
                                ),
                              ],
                            ),

                            // onTap: () {
                            // futuro: abrir detalle según tipo
                            //   },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
