// lib/ai/chat/widgets/chat_input.dart

import 'package:flutter/material.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';

class ChatInput extends StatefulWidget {
  final bool isLoading;
  final void Function(String) onSend;

  const ChatInput({super.key, required this.isLoading, required this.onSend});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final has = _ctrl.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send() {
    if (!_hasText || widget.isLoading) return;
    final text = _ctrl.text.trim();
    _ctrl.clear();
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AlmaSpacing.md,
          vertical: AlmaSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AlmaColors.background(isDark),
          border: Border(
            top: BorderSide(
              color: AlmaColors.border(isDark).withValues(alpha: 0.12),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Campo de texto
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 120),
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focus,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  style: AlmaTypography.bodyMedium(isDark, context),
                  decoration: InputDecoration(
                    hintText: 'Escribe algo...',
                    hintStyle: AlmaTypography.bodyMedium(
                      isDark,
                      context,
                    ).copyWith(color: AlmaColors.textMuted(isDark)),
                    filled: true,
                    fillColor: AlmaColors.surfaceVariant(isDark),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AlmaRadius.input),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AlmaSpacing.md,
                      vertical: AlmaSpacing.sm,
                    ),
                    isDense: true,
                  ),
                ),
              ),
            ),

            const SizedBox(width: AlmaSpacing.xs),

            // Botón de enviar
            AnimatedOpacity(
              opacity: _hasText && !widget.isLoading ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 150),
              child: GestureDetector(
                onTap: _send,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AlmaColors.textPrimary(isDark),
                    borderRadius: BorderRadius.circular(AlmaRadius.full),
                  ),
                  child: const Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
