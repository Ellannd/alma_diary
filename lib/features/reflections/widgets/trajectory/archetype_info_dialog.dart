import 'package:flutter/material.dart';

Future<void> showArchetypeInfoDialog(
  BuildContext context,
  String archetype,
) {
  final descriptions = {
    'The Mask':
        'Cuando tu lenguaje es formal o enfocado en el deber ser, puedes estar ocultando emociones auténticas.',

    'The Mirror':
        'Refleja tu capacidad de autoanálisis y proyección en otros. Indica autoconciencia.',

    'The Moon':
        'Simboliza la exploración de sueños, miedos e intuiciones. Representa tu mundo subconsciente.',
  };

  final description =
      descriptions[archetype] ??
      'Este arquetipo aún no tiene descripción disponible.';

  return showDialog(
    context: context,

    builder: (_) {
      return AlertDialog(
        backgroundColor:
            Theme.of(context).scaffoldBackgroundColor,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),

        title: Text(
          archetype,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context)
                .colorScheme
                .onSurface,
          ),
        ),

        content: Text(
          description,
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.85),
          ),
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },

            child: Text(
              'Cerrar',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
            ),
          ),
        ],
      );
    },
  );
}