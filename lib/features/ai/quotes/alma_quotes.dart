import 'package:flutter/material.dart';
import 'package:alma_diary/ai/engines/quotes_engine.dart';


class QuoteCard extends StatelessWidget {
  final AlmaQuote quote;
  final bool pinned;
  final VoidCallback onPin;

  const QuoteCard({
    super.key,
    required this.quote,
    required this.pinned,
    required this.onPin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: pinned
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quote.texto,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '- ${quote.autor}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Text(
            quote.contextoAlma,
            style: const TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onPin,
            child: Text(
              pinned ? 'Frase del día' : 'Anclar',
              style: TextStyle(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8)),
            ),
          ),
        ],
      ),
    );
  }
}
class AlmaQuotesScreen extends StatefulWidget {
  final String arquetipo;
  final List<String> nodosDolor;

  const AlmaQuotesScreen({
    super.key,
    required this.arquetipo,
    required this.nodosDolor,
  });

  @override
  State<AlmaQuotesScreen> createState() => _AlmaQuotesScreenState();
}

class _AlmaQuotesScreenState extends State<AlmaQuotesScreen> {
  late QuotesEngine _engine;

  List<AlmaQuote> _quotes = [];
  bool _loading = true;

  int _pinnedIndex = 0;

  @override
  void initState() {
    super.initState();

    _engine = QuotesEngine(
      arquetipo: widget.arquetipo,
      nodosDolor: widget.nodosDolor,
    );

    _loadQuotes();
  }
  
Future<void> _loadQuotes() async {
  setState(() => _loading = true);

  final data = await _engine.getDailyQuotes();

  if (!mounted) return;

  setState(() {
    _quotes = data;
    _loading = false;
  });
}

  void _pinQuote(int index) {
    setState(() {
      _pinnedIndex = index;
    });
  }

  @override
Widget build(BuildContext context) {
  final onSurface = Theme.of(context).colorScheme.onSurface;

  return Scaffold(
    appBar: AppBar(title: const Text('Frases del Alma')),

    body: _loading
        ? const Center(child: CircularProgressIndicator())

        : _quotes.isEmpty
            ? Center(
                child: Text(
                  'No hay frases disponibles.',
                  style: TextStyle(
                    color: onSurface.withValues(alpha: .6),
                  ),
                ),
              )

            : ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: _quotes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (context, i) {
                  return QuoteCard(
                    quote: _quotes[i],
                    pinned: i == _pinnedIndex,
                    onPin: () => _pinQuote(i),
                  );
                },
              ),
  );
}
}