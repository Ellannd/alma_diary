import 'package:flutter/material.dart';

enum AlmaTextVariant {
  displayLarge,
  displayMedium,
  h1,
  h2,
  h3,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
}

class AlmaText extends StatelessWidget {
  final String text;
  final AlmaTextVariant variant;
  final TextAlign? align;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;
  final FontWeight? weight;

  const AlmaText(
    this.text, {
    super.key,
    this.variant = AlmaTextVariant.bodyMedium,
    this.align,
    this.maxLines,
    this.overflow,
    this.color,
    this.weight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _resolveStyle(theme);

    return Text(
      text,
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
      style: style.copyWith(
        color: color ?? style.color,
        fontWeight: weight ?? style.fontWeight,
      ),
    );
  }

  TextStyle _resolveStyle(ThemeData theme) {
    switch (variant) {
      case AlmaTextVariant.displayLarge:
        return theme.textTheme.displayLarge!;
      case AlmaTextVariant.displayMedium:
        return theme.textTheme.displayMedium!;
      case AlmaTextVariant.h1:
        return theme.textTheme.headlineLarge!;
      case AlmaTextVariant.h2:
        return theme.textTheme.headlineMedium!;
      case AlmaTextVariant.h3:
        return theme.textTheme.headlineSmall!;
      case AlmaTextVariant.bodyLarge:
        return theme.textTheme.bodyLarge!;
      case AlmaTextVariant.bodyMedium:
        return theme.textTheme.bodyMedium!;
      case AlmaTextVariant.bodySmall:
        return theme.textTheme.bodySmall!;
      case AlmaTextVariant.labelLarge:
        return theme.textTheme.labelLarge!;
      case AlmaTextVariant.labelMedium:
        return theme.textTheme.labelMedium!;
      case AlmaTextVariant.labelSmall:
        return theme.textTheme.labelSmall!;
    }
  }
}