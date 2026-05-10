import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alma_diary/state/readings/readings_controller.dart';
import '../widgets/reading_card.dart';

class ReadingsPage extends ConsumerStatefulWidget {
  const ReadingsPage({super.key});

  @override
  ConsumerState<ReadingsPage> createState() => _ReadingsPageState();
}

class _ReadingsPageState extends ConsumerState<ReadingsPage> {
  final Set<String> _helped = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(readingsControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(readingsControllerProvider);
    final controller = ref.read(readingsControllerProvider.notifier);

    final loading = state.isLoading;
    final recs = state.readings;

    return Scaffold(
      appBar: AppBar(title: const Text('Lecturas')),

      body: loading
          ? const Center(child: CircularProgressIndicator())

          : recs.isEmpty
              ? const Center(child: Text('No hay lecturas'))

              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: recs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, i) {
                    final rec = recs[i];

                    return ReadingCard(
                      rec: rec,
                      saved: controller.isSaved(rec['id']),
                      helped: _helped.contains(rec['id']),

                      onSave: () => controller.toggleSave(rec['id']),

                      onHelped: () {
                        setState(() {
                          _helped.add(rec['id']);
                        });
                      },
                    );
                  },
                ),
    );
  }
}