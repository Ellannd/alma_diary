import 'package:alma_diary/features/search/domain/search_action.dart';
import 'package:flutter/material.dart';
import 'package:alma_diary/models/search_result.dart';
import 'package:alma_diary/features/search/utils/search_result_mapper.dart';

class SearchResultsList extends StatelessWidget {
  final List<SearchResult> results;
  final Function(SearchAction action) onAction;
  final Future<void> Function()? onRefresh;

  const SearchResultsList({
    super.key,
    required this.results,
    required this.onAction,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
        itemCount: results.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (_, index) {
          final item = results[index];
          final visual = _resolveVisual(item.type);

          return InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              final action = SearchResultMapper.toAction(item);
              onAction(action);
            },
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: visual.color.withValues(alpha: 0.12),
                    ),
                    child: Icon(
                      visual.icon,
                      color: visual.color,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          item.subtitle,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.65),
                            height: 1.45,
                            fontSize: 13.5,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: visual.color.withValues(alpha: 0.12),
                              ),
                              child: Text(
                                item.type.toUpperCase(),
                                style: TextStyle(
                                  color: visual.color,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),

                            const Spacer(),

                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.35),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _SearchVisual _resolveVisual(String type) {
    switch (type) {
      case 'journal':
        return _SearchVisual(
          icon: Icons.menu_book_rounded,
          color: Colors.blue,
        );

      case 'reflection':
        return _SearchVisual(
          icon: Icons.psychology_alt_rounded,
          color: Colors.purple,
        );

      case 'challenge':
        return _SearchVisual(
          icon: Icons.workspace_premium_rounded,
          color: Colors.orange,
        );

      case 'quote':
        return _SearchVisual(
          icon: Icons.format_quote_rounded,
          color: Colors.green,
        );

      default:
        return _SearchVisual(
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