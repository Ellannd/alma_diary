import 'package:flutter/material.dart';

class SearchResultIcon extends StatelessWidget {
  final String type;

  const SearchResultIcon({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final visual = _resolveVisual(type);

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: visual.color.withValues(alpha: 0.12),
      ),
      child: Icon(
        visual.icon,
        color: visual.color,
        size: 24,
      ),
    );
  }

  _SearchVisual _resolveVisual(String type) {
    switch (type) {
      case 'journal':
        return const _SearchVisual(
          icon: Icons.menu_book_rounded,
          color: Colors.blue,
        );

      case 'reflection':
        return const _SearchVisual(
          icon: Icons.psychology_alt_rounded,
          color: Colors.purple,
        );

      case 'challenge':
        return const _SearchVisual(
          icon: Icons.workspace_premium_rounded,
          color: Colors.orange,
        );

      case 'quote':
        return const _SearchVisual(
          icon: Icons.format_quote_rounded,
          color: Colors.green,
        );

      default:
        return const _SearchVisual(
          icon: Icons.search_rounded,
          color: Colors.grey,
        );
    }
  }
}

class _SearchVisual {
  final IconData icon;
  final Color color;

  const _SearchVisual({
    required this.icon,
    required this.color,
  });
}