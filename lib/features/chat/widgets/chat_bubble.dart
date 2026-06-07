// lib/ai/chat/widgets/chat_bubble.dart

import 'package:flutter/material.dart';
import 'package:alma_diary/ai/chat/domain/chat_message.dart';
import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_typography.dart';
import 'package:alma_diary/design_system/tokens/alma_radius.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  bool get _isUser => message.isUser;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        left: _isUser ? 64 : 0,
        right: _isUser ? 0 : 16,
        bottom: AlmaSpacing.xs,
      ),
      child: Align(
        alignment: _isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: _isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Avatar de Alma solo en mensajes del asistente
            if (!_isUser) _AlmaAvatar(isDark: isDark),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AlmaSpacing.md,
                vertical: AlmaSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: _isUser
                    ? AlmaColors.accent(isDark)
                    : AlmaColors.surfaceVariant(isDark),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AlmaRadius.lg),
                  topRight: const Radius.circular(AlmaRadius.lg),
                  bottomLeft: Radius.circular(
                    _isUser ? AlmaRadius.lg : AlmaRadius.xs,
                  ),
                  bottomRight: Radius.circular(
                    _isUser ? AlmaRadius.xs : AlmaRadius.lg,
                  ),
                ),
              ),

              child: MarkdownBody(
                data: message.content,
                styleSheet: MarkdownStyleSheet(
                  p: AlmaTypography.bodyMedium(isDark, context).copyWith(
                    color: _isUser
                        ? Colors.white
                        : AlmaColors.textPrimary(isDark),
                    height: 1.5,
                  ),
                  strong: AlmaTypography.bodyMedium(isDark, context).copyWith(
                    color: _isUser
                        ? Colors.white
                        : AlmaColors.textPrimary(isDark),
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                  em: AlmaTypography.bodyMedium(isDark, context).copyWith(
                    color: _isUser
                        ? Colors.white
                        : AlmaColors.textPrimary(isDark),
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                  blockquote: AlmaTypography.bodyMedium(isDark, context)
                      .copyWith(
                        color: _isUser
                            ? Colors.white70
                            : AlmaColors.textSecondary(isDark),
                        height: 1.5,
                      ),
                  blockquoteDecoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: _isUser
                            ? Colors.white38
                            : AlmaColors.accent(isDark),
                        width: 3,
                      ),
                    ),
                  ),
                  code: AlmaTypography.bodySmall(isDark, context).copyWith(
                    color: _isUser ? Colors.white : AlmaColors.accent(isDark),
                    fontFamily: 'monospace',
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: _isUser
                        ? Colors.black12
                        : AlmaColors.surfaceVariant(isDark),
                    borderRadius: BorderRadius.circular(AlmaRadius.sm),
                  ),
                  listBullet: AlmaTypography.bodyMedium(isDark, context)
                      .copyWith(
                        color: _isUser
                            ? Colors.white
                            : AlmaColors.textPrimary(isDark),
                      ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            // Timestamp
            Text(
              _formatTime(message.timestamp),
              style: AlmaTypography.labelSmall(
                isDark,
                context,
              ).copyWith(color: AlmaColors.textMuted(isDark)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

// Avatar de Alma — círculo con la inicial del acento
class _AlmaAvatar extends StatelessWidget {
  final bool isDark;
  const _AlmaAvatar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AlmaColors.accentSoft(isDark),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              'A',
              style: AlmaTypography.labelSmall(isDark).copyWith(
                color: AlmaColors.accent(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: AlmaSpacing.xs),
        Text(
          'Alma',
          style: AlmaTypography.labelSmall(
            isDark,
          ).copyWith(color: AlmaColors.textMuted(isDark)),
        ),
      ],
    );
  }
}
