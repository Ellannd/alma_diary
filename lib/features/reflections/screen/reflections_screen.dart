import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter/material.dart";

import "package:alma_diary/state/reflections/reflection_controller.dart";
import "package:alma_diary/features/reflections/widgets/reflection_entry_card.dart";
import "package:alma_diary/features/reflections/widgets/reflection_detail_dialog.dart";

class AlmaReflectionsScreen extends ConsumerStatefulWidget {
  const AlmaReflectionsScreen({super.key});

  @override
  ConsumerState<AlmaReflectionsScreen> createState() =>
      _AlmaReflectionsScreenState();
}

class _AlmaReflectionsScreenState
    extends ConsumerState<AlmaReflectionsScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(reflectionControllerProvider.notifier).loadEntries());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reflectionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reflexiones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(reflectionControllerProvider.notifier)
                .refresh(),
          ),
        ],
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.entries.isEmpty
              ? Center(
                  child: Text(
                    state.error ?? 'No hay entradas aún.',
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.entries.length,
                  itemBuilder: (context, i) {
                    final entry = state.entries[i];

                    return ReflectionEntryCard(
                      entry: entry,
                      onTap: () {
                                showReflectionDetail(
                                  context: context,
                                  entry: entry,
                                );
                              },
                    );
                  },
                ),
    );
  }
}