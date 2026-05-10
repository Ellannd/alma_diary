import '../domain/search_action.dart';
import 'package:alma_diary/models/search_result.dart';

class SearchResultMapper {
  static SearchAction toAction(SearchResult r) {
    switch (r.type) {
      case 'journal':
        return OpenJournalAction(r.entry);

      case 'reflection':
        return OpenReflectionAction(r.entry);

      case 'challenge':
        return OpenChallengeAction(r.entry);

      case 'quote':
        return OpenQuoteAction(r.entry);

      default:
        throw Exception('Unknown type: ${r.type}');
    }
  }
}