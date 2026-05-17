// lib/features/journal/screens/journal_editor_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alma_diary/state/journal/journal_controller.dart';

import '../widgets/journal_editor.dart';
import '../widgets/journal_save_button.dart';
import '../widgets/journal_loading_overlay.dart';
import '../widgets/journal_error_banner.dart';
import '../widgets/journal_empty_state.dart';

import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';

class JournalEditorScreen
    extends ConsumerStatefulWidget {
  const JournalEditorScreen({super.key});

  @override
  ConsumerState<JournalEditorScreen>
      createState() =>
          _JournalEditorScreenState();
}

class _JournalEditorScreenState
    extends ConsumerState<JournalEditorScreen> {
  late final TextEditingController
      _textController;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final controller = ref.read(
      journalControllerProvider.notifier,
    );

    final content =
        _textController.text.trim();

    if (content.isEmpty) return;

    final entryId =
        await controller.createEntry(
      content: content,
    );

    if (!mounted) return;

    if (entryId != null) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final state =
        ref.watch(journalControllerProvider);

    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,

      appBar: AppBar(
        elevation: 0,
      ),

      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(
                AlmaSpacing.r(context, AlmaSpacing.lg)
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  // =====================
                  // EDITOR
                  // =====================
                  Expanded(
                    child: JournalEditor(
                      controller:
                          _textController,
                          hintText: "Escribe tus pensamientos.",
                  
                    ),
                  ),

                  SizedBox(
                    height: AlmaSpacing.r(context, AlmaSpacing.lg),
                  ),

                  // =====================
                  // SAVE BUTTON
                  // =====================
                  JournalSaveButton(
                    loading:
                        state.saving ||
                            state.analyzing,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ),

          // =========================
          // LOADING OVERLAY
          // =========================
          if (state.saving ||
              state.analyzing)
            const JournalLoadingOverlay(label: "Analizando entrada..."),
        ],
      ),
    );
  }
}