import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:alma_diary/features/search/search_service.dart";
import "package:alma_diary/state/search/search_state.dart";
import "package:alma_diary/state/search/search_controller.dart";

final searchControllerProvider =
    NotifierProvider<SearchController, SearchState>(
  SearchController.new,
);

final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService();
});