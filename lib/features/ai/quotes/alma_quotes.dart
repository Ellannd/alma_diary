import 'package:flutter/material.dart';
import 'package:alma_diary/features/ai/quotes/engine/quotes_engine.dart';


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
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),

        // 🎨 COLOR DINÁMICO
        color: pinned
            ? primary.withValues(alpha: 0.18)
            : theme.cardColor.withValues(alpha: 0.85),

        // 🌟 BORDE SOLO SI ESTÁ ANCLADA
        border: Border.all(
          color: pinned ? primary : Colors.transparent,
          width: 1.5,
        ),

        // 💡 SOMBRA EMOCIONAL
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: pinned ? 0.25 : 0.08),
            blurRadius: pinned ? 20 : 10,
            spreadRadius: pinned ? 2 : 0,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🪶 ICONO SUTIL
          Icon(
            Icons.format_quote,
            size: 26,
            color: primary.withValues(alpha: 0.6),
          ),

          const SizedBox(height: 12),

          // ✍️ FRASE
          Text(
            quote.texto,
            style: TextStyle(
              fontSize: pinned ? 19 : 17,
              height: 1.5,
              fontStyle: FontStyle.italic,
              color: onSurface,
              fontWeight: pinned ? FontWeight.w500 : FontWeight.normal,
            ),
          ),

          const SizedBox(height: 12),

          // 👤 AUTOR
          Text(
            '- ${quote.autor}',
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 12),

          // 🧠 CONTEXTO (más suave)
          Text(
            quote.contextoAlma,
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.55),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),

          // 📌 ACTION ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (pinned)
                Text(
                  'Frase del día',
                  style: TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

              GestureDetector(
                onTap: onPin,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: pinned ? 1.2 : 1.0,
                  child: Icon(
                    pinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: pinned
                        ? primary
                        : onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
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
    appBar: AppBar(title: const Text('Alma')),

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

            : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // HEADER
            Text(
              'Frases',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Palabras que pueden resonar contigo hoy',
              style: TextStyle(
                fontSize: 14,
                color: onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),

            // LISTA
            ...List.generate(_quotes.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: QuoteCard(
                  quote: _quotes[i],
                  pinned: i == _pinnedIndex,
                  onPin: () => _pinQuote(i),
                ),
              );
            }),
          ],
        ),
      )
      );
    }
}