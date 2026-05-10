import 'package:flutter/material.dart';

class TrajectorySectionTitle extends StatelessWidget {
  final String title;

  const TrajectorySectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}