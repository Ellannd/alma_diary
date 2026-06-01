import "package:alma_diary/design_system/tokens/alma_colors.dart";
import "package:alma_diary/design_system/tokens/alma_spacing.dart";
import "package:flutter/material.dart";
import 'reflection_date_chip.dart';
import "reflection_tags.dart";

class ReflectionEntryCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final VoidCallback onTap;
  final VoidCallback onEditTitle;  
  final VoidCallback onEditEntry;   
  final VoidCallback onDelete;

  const ReflectionEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onEditTitle,
    required this.onEditEntry,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final content = entry['content_decrypted'] ?? '';
    final rawTitle = entry['title'] as String?;
    final title = rawTitle?.split(" ").lastOrNull ?? ''; 
     //Ya que el titulo contiene una fecha. Si se muestra la fecha se repite con el reflection date chip,
     // por eso se muestra solo la última palabra. Que es el dia de la semana, 
     //todo: ver si el titulo se vuelve más complejo en el futuro 

    final archetype = entry['archetype'] ?? '';
    final sentiment = entry['sentiment'] ?? '';

    final rawDate = entry['created_at'];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final date = DateTime.tryParse(rawDate?.toString() ?? '') ??
        DateTime.now();

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: AlmaSpacing.r(context, 16),
          vertical: AlmaSpacing.r(context, 10),
        ),
        padding: EdgeInsets.all(AlmaSpacing.r(context, 18)),
        decoration: BoxDecoration(
          border: Border.all(
            color: AlmaColors.textPrimary(isDark).withValues(alpha: 0.80),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Fecha + menú ──────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReflectionDateChip(date: date),
                      if (title.isNotEmpty) ...[
                        SizedBox(height: AlmaSpacing.r(context, 4)),
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: AlmaSpacing.r(context, 15),
                            color: AlmaColors.textPrimary(isDark),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Tres puntos ───────────────────────────
                _EntryMenu(
                  onEditTitle: onEditTitle,
                  onEditEntry: onEditEntry,
                  onDelete: onDelete,
                ),
              ],
            ),

            SizedBox(height: AlmaSpacing.r(context, 12)),
            ReflectionTags(archetype: archetype, sentiment: sentiment),
            SizedBox(height: AlmaSpacing.r(context, 14)),

            Text(
              content.length > 140
                  ? '${content.substring(0, 140)}...'
                  : content,
            ),

            SizedBox(height: AlmaSpacing.r(context, 10)),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.arrow_forward_ios,
                size: AlmaSpacing.r(context, 14),
                color: Colors.grey.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Menú aislado en su propio widget ─────────────────────────────────────────
class _EntryMenu extends StatelessWidget {
  final VoidCallback onEditTitle;
  final VoidCallback onEditEntry;
  final VoidCallback onDelete;

  const _EntryMenu({
    required this.onEditTitle,
    required this.onEditEntry,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopupMenuButton<_EntryAction>(
      icon: Icon(
        Icons.more_horiz,
        color: AlmaColors.textMuted(isDark),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (action) {
        switch (action) {
          case _EntryAction.editTitle:
            onEditTitle();
          case _EntryAction.editEntry:
            onEditEntry();
          case _EntryAction.delete:
            onDelete();
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: _EntryAction.editTitle,
          child: ListTile(
            leading: Icon(Icons.title_outlined),
            title: Text('Editar título'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: _EntryAction.editEntry,
          child: ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('Editar entrada'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: _EntryAction.delete,
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: Colors.redAccent),
            title: Text('Borrar entrada',
                style: TextStyle(color: Colors.redAccent)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

enum _EntryAction { editTitle, editEntry, delete }
