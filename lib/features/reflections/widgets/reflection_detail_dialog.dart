import 'dart:ui';

import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';
import 'package:flutter/material.dart';

import 'package:alma_diary/features/reflections/widgets/reflection_card.dart';
import 'package:alma_diary/features/reflections/widgets/reflection_tags.dart';

Future<void> showReflectionDetail({
  required BuildContext context,
  required Map<String, dynamic> entry,
}) {
  final content = entry['content_decrypted'] ?? 'Sin contenido';
final reflection = entry['analysis_decrypted'] ?? '';

  final archetype = entry['archetype'] ?? 'The Mirror';
  final sentiment = entry['sentiment'] ?? 'neutral';

  final rawDate = entry['created_at'];

  final date =
      DateTime.tryParse(rawDate?.toString() ?? '') ??
      DateTime.now();

  return showDialog(
    context: context,
    builder: (ctx) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 8,
        sigmaY: 8,
      ),
      child: Dialog(
        
        backgroundColor: AlmaColors.transparent,
        insetPadding: EdgeInsets.all(AlmaSpacing.r(context, 16)),

        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),

          child: SingleChildScrollView(
            padding: EdgeInsets.all(AlmaSpacing.r(context, 24)),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      'Entrada '
                      '${date.day.toString().padLeft(2, '0')}/'
                      '${date.month.toString().padLeft(2, '0')}/'
                      '${date.year}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AlmaColors.lightBackground,
                      ),
                    ),

                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AlmaColors.lightBackground,
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),

                SizedBox(height: AlmaSpacing.r(context, AlmaSpacing.screenPadding)),

                // TAGS
                ReflectionTags(
                  archetype: archetype,
                  sentiment: sentiment,
                ),

                SizedBox(height: AlmaSpacing.r(context, AlmaSpacing.screenPadding)),

                // ENTRY CONTENT
                Container(
                  padding: EdgeInsets.all(AlmaSpacing.r(context, AlmaSpacing.md)),

                  decoration: BoxDecoration(
                    color: AlmaColors.glass(Theme.of(context).brightness == Brightness.dark),
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Text(
                    content,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),

                SizedBox(height: AlmaSpacing.r(context, AlmaSpacing.lg)),

                // REFLECTION
                if (reflection.isNotEmpty) ...[
                  Text(
                    'Reflexión de Alma',
                    style: TextStyle(
                      fontSize: AlmaSpacing.r(context, 18),
                      fontWeight: FontWeight.bold,
                      color:
                          AlmaColors.lightBackground,
                    ),
                  ),

                SizedBox(height: AlmaSpacing.r(context, AlmaSpacing.md)),

                  ReflectionCard(
                    reflection: reflection,
                    archetype: archetype,
                    sentiment: sentiment,
                  ),
                ] else
                  Text(
                    'No hay reflexión disponible.',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),

                SizedBox(height: AlmaSpacing.r(context, AlmaSpacing.lg)),

                Align(
                  alignment: Alignment.centerRight,

                  child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AlmaColors.info, 
                        ),
                    
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },

                    icon: Icon(
                      Icons.arrow_forward,
                      size: AlmaSpacing.r(context, 18),
                      color: AlmaColors.info,
                    ),

                    label: const Text('Continuar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
      );
      
    },
  );
}