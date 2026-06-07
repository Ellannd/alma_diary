// lib/ai/chat/widgets/chat_history_sheet.dart

import 'package:alma_diary/state/chat/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alma_diary/ai/chat/domain/chat_conversation.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';

class ChatHistorySheet extends ConsumerWidget {
  const ChatHistorySheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const ChatHistorySheet(),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(chatProvider);
    final conversations = state.conversations;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: AlmaColors.surface(isDark),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AlmaRadius.sheet),
          ),
        ),
        child: Column(
          children: [
            // Handle
            _SheetHandle(isDark: isDark),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AlmaSpacing.md,
                vertical: AlmaSpacing.sm,
              ),
              child: Row(
                children: [
                  Text('Conversaciones', style: AlmaTypography.h3(isDark)),
                  const Spacer(),
                  // Nueva conversación
                  _NewChatButton(isDark: isDark),
                ],
              ),
            ),

            const Divider(height: 1),

            // Lista
            Expanded(
              child: state.isLoadingConversations
                  ? const Center(child: CircularProgressIndicator())
                  : conversations.isEmpty
                  ? _EmptyHistory(isDark: isDark)
                  : ListView.separated(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.symmetric(
                        vertical: AlmaSpacing.xs,
                      ),
                      itemCount: conversations.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        indent: AlmaSpacing.md,
                        endIndent: AlmaSpacing.md,
                        color: AlmaColors.border(isDark).withValues(alpha: 0.1),
                      ),
                      itemBuilder: (context, i) => _ConversationTile(
                        conversation: conversations[i],
                        isActive:
                            state.activeConversation?.id == conversations[i].id,
                        isDark: isDark,
                        onTap: () {
                          ref
                              .read(chatProvider.notifier)
                              .loadConversation(conversations[i]);
                          Navigator.of(context).pop();
                        },
                        onDelete: () => ref
                            .read(chatProvider.notifier)
                            .deleteConversation(conversations[i].id),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Subwidgets ───────────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  final bool isDark;
  const _SheetHandle({required this.isDark});

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: AlmaSpacing.sm),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AlmaColors.textMuted(isDark).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AlmaRadius.full),
      ),
    ),
  );
}

class _NewChatButton extends ConsumerWidget {
  final bool isDark;
  const _NewChatButton({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) => TextButton.icon(
    onPressed: () {
      ref.read(chatProvider.notifier).newConversation();
      Navigator.of(context).pop();
    },
    icon: Icon(Icons.add_rounded, size: 18, color: AlmaColors.accent(isDark)),
    label: Text(
      'Nueva',
      style: AlmaTypography.labelMedium(
        isDark,
      ).copyWith(color: AlmaColors.accent(isDark)),
    ),
  );
}

class _ConversationTile extends StatelessWidget {
  final ChatConversation conversation;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ConversationTile({
    required this.conversation,
    required this.isActive,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Dismissible(
    key: ValueKey(conversation.id),
    direction: DismissDirection.endToStart,
    confirmDismiss: (_) => _confirmDelete(context, isDark),
    onDismissed: (_) => onDelete(),
    background: Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AlmaSpacing.md),
      color: AlmaColors.error.withValues(alpha: 0.1),
      child: Icon(
        Icons.delete_outline_rounded,
        color: AlmaColors.error,
        size: 20,
      ),
    ),
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AlmaSpacing.md,
        vertical: AlmaSpacing.xxs,
      ),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isActive
              ? AlmaColors.accentSoft(isDark)
              : AlmaColors.surfaceVariant(isDark),
          borderRadius: BorderRadius.circular(AlmaRadius.sm),
        ),
        child: Icon(
          Icons.chat_bubble_outline_rounded,
          size: 18,
          color: isActive
              ? AlmaColors.accent(isDark)
              : AlmaColors.textMuted(isDark),
        ),
      ),
      title: Text(
        conversation.title,
        style: AlmaTypography.bodyMedium(isDark).copyWith(
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          color: isActive
              ? AlmaColors.accent(isDark)
              : AlmaColors.textPrimary(isDark),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        conversation.formattedDate,
        style: AlmaTypography.labelSmall(
          isDark,
        ).copyWith(color: AlmaColors.textMuted(isDark)),
      ),
      trailing: isActive
          ? Icon(Icons.circle, size: 8, color: AlmaColors.accent(isDark))
          : null,
    ),
  );

  Future<bool?> _confirmDelete(
    BuildContext context,
    bool isDark,
  ) => showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AlmaColors.surface(isDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AlmaRadius.md),
      ),
      title: Text('Eliminar conversación', style: AlmaTypography.h3(isDark)),
      content: Text(
        '¿Seguro? Esta acción no se puede deshacer.',
        style: AlmaTypography.bodySmall(
          isDark,
        ).copyWith(color: AlmaColors.textSecondary(isDark)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancelar',
            style: TextStyle(color: AlmaColors.textMuted(isDark)),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Eliminar', style: TextStyle(color: AlmaColors.error)),
        ),
      ],
    ),
  );
}

class _EmptyHistory extends StatelessWidget {
  final bool isDark;
  const _EmptyHistory({required this.isDark});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.chat_bubble_outline_rounded,
          size: 40,
          color: AlmaColors.textMuted(isDark),
        ),
        const SizedBox(height: AlmaSpacing.sm),
        Text(
          'Sin conversaciones aún',
          style: AlmaTypography.bodyMedium(
            isDark,
          ).copyWith(color: AlmaColors.textMuted(isDark)),
        ),
      ],
    ),
  );
}
