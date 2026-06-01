import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alma_diary/state/journal/journal_controller.dart';

import '../widgets/journal_editor.dart';
import '../widgets/journal_save_button.dart';
import '../widgets/journal_loading_overlay.dart';

import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';

class JournalEditorScreen extends ConsumerStatefulWidget {
  const JournalEditorScreen({super.key});

  @override
  ConsumerState<JournalEditorScreen> createState() =>
      _JournalEditorScreenState();
}

class _JournalEditorScreenState
    extends ConsumerState<JournalEditorScreen> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final content = _textController.text.trim();
    if (content.isEmpty) return;

    final controller = ref.read(journalControllerProvider.notifier);
    final entryId = await controller.createEntry(content: content);

    if (!mounted) return;
    if (entryId != null) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(
      journalControllerProvider.select((s) => s.saving),
    );
    final isAnalyzing = ref.watch(
      journalControllerProvider.select((s) => s.analyzing),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AlmaColors.background(isDark),
      resizeToAvoidBottomInset: false, // lo manejamos manualmente
      appBar: AppBar(
        backgroundColor: AlmaColors.background(isDark),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // =====================
          // CONTENIDO PRINCIPAL
          // =====================
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AlmaSpacing.r(context, AlmaSpacing.lg),
                0,
                AlmaSpacing.r(context, AlmaSpacing.lg),
                //  padding bottom dinámico según teclado
                bottomInset +
                    AlmaSpacing.r(context, 80), // espacio para el botón
              ),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: JournalEditor(
                  controller: _textController,
                  focusNode: _focusNode,
                  hintText: 'Escribe tus pensamientos.',
                ),
              ),
            ),
          ),

          // =====================
          // BOTÓN FLOTANTE ABAJO
          // =====================
          Positioned(
            left: AlmaSpacing.r(context, AlmaSpacing.lg),
            right: AlmaSpacing.r(context, AlmaSpacing.lg),
            //  sube con el teclado
            bottom: bottomInset + AlmaSpacing.r(context, AlmaSpacing.lg),
            child: 
                JournalSaveButton(
                  loading: isSaving || isAnalyzing,
                  onPressed: _save,
                ),
        
          ),

          // =====================
          // LOADING OVERLAY
          // =====================
          if (isSaving || isAnalyzing)
            const JournalLoadingOverlay(label: 'Analizando entrada...'),
        ],
      ),
    );
  }
}