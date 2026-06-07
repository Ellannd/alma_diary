// lib/ai/chat/screens/chat_screen.dart

import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/features/chat/widgets/chat_bubble.dart';
import 'package:alma_diary/features/chat/widgets/chat_history_sheet.dart';
import 'package:alma_diary/features/chat/widgets/chat_input.dart';
import 'package:alma_diary/features/chat/widgets/chat_typing_indicator.dart';
import 'package:alma_diary/features/chat/widgets/similar_entries_strip.dart';
import 'package:alma_diary/state/chat/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';

class ChatScreen extends ConsumerStatefulWidget {
  /// Contexto opcional — si viene de un journal entry,
  /// se muestra como chip de contexto activo
  final String? journalContext;

  const ChatScreen({super.key, this.journalContext});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(chatProvider);

    // Scroll al fondo cuando llega un mensaje nuevo
    ref.listen(chatProvider, (prev, next) {
      if (next.messages.length != prev?.messages.length ||
          next.isLoading != prev?.isLoading) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: AlmaColors.background(isDark),
      appBar: _ChatAppBar(isDark: isDark),
      body: Column(
        children: [
          // Chip de contexto si viene de un journal entry
          if (widget.journalContext != null)
            _ContextChip(text: widget.journalContext!, isDark: isDark),

          // Error banner
          if (state.hasError)
            _ErrorBanner(
              message: 'No pude conectar. Intenta de nuevo.',
              isDark: isDark,
              onDismiss: () => ref.read(chatProvider.notifier).clearError(),
            ),

          // Lista de mensajes
          Expanded(
            child: state.hasMessages
                ? ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AlmaSpacing.md,
                      vertical: AlmaSpacing.md,
                    ),
                    itemCount:
                        state.messages.length + (state.isLoading ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == state.messages.length) {
                        return const ChatTypingIndicator();
                      }

                      final message = state.messages[i];
                      final isLastAssistant =
                          !message.isUser &&
                          i == state.messages.length - 1 &&
                          state.similarEntries.isNotEmpty;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ChatBubble(message: message),
                          if (isLastAssistant)
                            SimilarEntriesStrip(
                              entries: state.similarEntries,
                              isDark: isDark,
                            ),
                        ],
                      );
                    },
                  )
                : _EmptyState(isDark: isDark),
          ),

          // Input
          ChatInput(
            isLoading: state.isLoading,
            onSend: (text) => ref.read(chatProvider.notifier).sendMessage(text),
          ),
        ],
      ),
    );
  }
}

// ── Subwidgets internos ──────────────────────────────────────────

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDark;
  const _ChatAppBar({required this.isDark});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AlmaColors.background(isDark),
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: AlmaColors.textPrimary(isDark),
          size: 20,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AlmaColors.accentSoft(isDark),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'A',
                style: AlmaTypography.labelLarge(isDark).copyWith(
                  color: AlmaColors.accent(isDark),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: AlmaSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alma',
                style: AlmaTypography.labelLarge(
                  isDark,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                'tu asistente personal',
                style: AlmaTypography.labelSmall(
                  isDark,
                ).copyWith(color: AlmaColors.textMuted(isDark)),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.history_rounded,
            color: AlmaColors.textPrimary(isDark),
            size: 20,
          ),
          tooltip: 'Historial',
          onPressed: () => ChatHistorySheet.show(context),
        ),
        Consumer(
          builder: (context, ref, _) => IconButton(
            icon: Icon(
              Icons.add_rounded,
              color: AlmaColors.textMuted(isDark),
              size: 20,
            ),
            tooltip: 'Nueva conversación',
            onPressed: () => ref.read(chatProvider.notifier).newConversation(),
          ),
        ),
      ],
    );
  }
}

class _ContextChip extends StatelessWidget {
  final String text;
  final bool isDark;
  const _ContextChip({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: AlmaSpacing.md,
        vertical: AlmaSpacing.xs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AlmaSpacing.md,
        vertical: AlmaSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AlmaColors.accentSoft(isDark),
        borderRadius: BorderRadius.circular(AlmaRadius.sm),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_stories_rounded,
            size: 14,
            color: AlmaColors.accent(isDark),
          ),
          const SizedBox(width: AlmaSpacing.xs),
          Expanded(
            child: Text(
              'Hablando sobre: $text',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AlmaTypography.labelSmall(
                isDark,
              ).copyWith(color: AlmaColors.accent(isDark)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final bool isDark;
  final VoidCallback onDismiss;

  const _ErrorBanner({
    required this.message,
    required this.isDark,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: AlmaSpacing.md,
        vertical: AlmaSpacing.xxs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AlmaSpacing.md,
        vertical: AlmaSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AlmaColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AlmaRadius.sm),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 14, color: AlmaColors.error),
          const SizedBox(width: AlmaSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: AlmaTypography.labelSmall(
                isDark,
              ).copyWith(color: AlmaColors.error),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close_rounded, size: 14, color: AlmaColors.error),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AlmaColors.accentSoft(isDark),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'A',
                style: AlmaTypography.h2(
                  isDark,
                ).copyWith(color: AlmaColors.accent(isDark)),
              ),
            ),
          ),
          const SizedBox(height: AlmaSpacing.md),
          Text(
            'Hola, soy Alma',
            style: AlmaTypography.h3(
              isDark,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AlmaSpacing.xs),
          Text(
            'Estoy aquí para acompañarte.\n¿Sobre qué quieres hablar hoy?',
            textAlign: TextAlign.center,
            style: AlmaTypography.bodySmall(
              isDark,
            ).copyWith(color: AlmaColors.textSecondary(isDark)),
          ),
        ],
      ),
    );
  }
}
