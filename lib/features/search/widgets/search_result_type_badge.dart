import 'package:flutter/material.dart';
//todo dont hardcode any colors
class SearchResultTypeBadge extends StatelessWidget {
  final String type;

  const SearchResultTypeBadge({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final color = _resolveColor(type);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: color.withValues(alpha: 0.12),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Color _resolveColor(String type) {
    switch (type) {
      case 'journal':
        return Colors.blue;

      case 'reflection':
        return Colors.purple;

      case 'challenge':
        return Colors.orange;

      case 'quote':
        return Colors.green;

      default:
        return Colors.grey;
    }
  }
}