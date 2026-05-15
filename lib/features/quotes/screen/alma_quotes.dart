import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:flutter/material.dart';
import "package:alma_diary/state/quotes/quote_controller.dart";
import 'package:alma_diary/state/dashboard/dashboard_controller.dart';

import "package:alma_diary/features/quotes/widgets/quote_card.dart";

class AlmaQuotesScreen extends ConsumerStatefulWidget {

  const AlmaQuotesScreen({
    super.key,
  });

  @override
  ConsumerState<AlmaQuotesScreen> createState() => _AlmaQuotesScreenState();
}

class _AlmaQuotesScreenState extends ConsumerState<AlmaQuotesScreen> {
  @override
  void initState() {
    super.initState();

    final dashboard = ref.watch(dashboardControllerProvider);

    final archetype = dashboard.archetype;

    final controller = ref.read(quotesControllerProvider.notifier);

    controller.init(
      arquetipo: archetype,
      nodosDolor: dashboard.painNodes,
    );

    controller.loadQuotes();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quotesControllerProvider);

    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('Alma')),

      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.quotes.isEmpty
              ? Center(
                  child: Text(
                    'No hay frases disponibles.',
                    style: TextStyle(
                      color: onSurface.withValues(alpha: .6),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 12),

                    ...List.generate(state.quotes.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: QuoteCard(
                          quote: state.quotes[i],
                          pinned: i == state.pinnedIndex,
                          onPin: () {
                            ref
                                .read(quotesControllerProvider.notifier)
                                .pinQuote(i);
                          },
                        ),
                      );
                    }),
                  ],
                ),
    );
  }
}