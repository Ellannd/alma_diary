import 'package:alma_diary/design_system/components/feedback/alma_loader.dart';
import "package:alma_diary/core/navigation/app_routes.dart";
import "package:alma_diary/design_system/tokens/alma_colors.dart";
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

  Future<void> _showEditTitleDialog(
  BuildContext context,
  Map<String, dynamic> entry,
) async {
  final controller = TextEditingController(text: entry['title'] as String? ?? '');

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Editar título'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Título de la entrada'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Guardar'),
        ),
      ],
    ),
  );

  if (confirmed == true && mounted) {
    await ref.read(reflectionControllerProvider.notifier).updateTitle(
      entryId: entry['id'] as String,
      title: controller.text.trim(),
    );
  }
}

Future<void> _showDeleteConfirmation(
  BuildContext context,
  String entryId,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('¿Borrar entrada?'),
      content: const Text('Esta acción no se puede deshacer.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Borrar', style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    ),
  );

  if (confirmed == true && mounted) {
    await ref.read(reflectionControllerProvider.notifier).deleteEntry(entryId);
  }
}

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
    reflectionControllerProvider.select((s) => s.loading),
  );
  final entries = ref.watch(
    reflectionControllerProvider.select((s) => s.entries),
  );
  final error = ref.watch(
    reflectionControllerProvider.select((s) => s.error),
  );
  final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AlmaColors.background(isDark),
      appBar: AppBar(
        title: const Text('Reflexiones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(reflectionControllerProvider.notifier)
                .refresh(),
          ),
        ],

      ),
      body: isLoading
          ? const Center(child: AlmaLoader())
          : entries.isEmpty
              ? Center(
                  child: Text(
                    error ?? 'No hay entradas aún.',
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: entries.length,
                  itemBuilder: (context, i) {
                    final entry = entries[i];

                    return ReflectionEntryCard(
                    entry: entry,
                    onTap: () => showReflectionDetail(context: context, entry: entry),

                    onEditTitle: () => _showEditTitleDialog(context, entry),

                    onEditEntry: () {
                      // Navega al editor con la entrada precargada
                      Navigator.pushNamed(context, AppRoutes.journal, arguments: entry);
                    },

                    onDelete: () => _showDeleteConfirmation(context, entry['id'] as String),
                  );
                  },
                ),
    );
  }
}
