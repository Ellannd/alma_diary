import 'package:alma_diary/state/search/search_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:alma_diary/state/search/search_controller.dart';
import 'package:alma_diary/features/search/widgets/archetype_filter_chips.dart';
import 'package:alma_diary/features/search/widgets/search_loading_view.dart';
import 'package:alma_diary/features/search/widgets/search_empty_state.dart';
import 'package:alma_diary/features/search/widgets/search_result_list.dart';
import "package:alma_diary/features/search/domain/search_action.dart";
import "package:alma_diary/features/search/dialogs/challenge_detail_sheet.dart";
import "package:alma_diary/features/search/dialogs/search_entry_detail_dialog.dart";

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({
    super.key,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedArchetype;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onQueryChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    final query = _controller.text.trim();
    _triggerSearch(query);
  }

  void _triggerSearch(String query) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    ref.read(searchControllerProvider.notifier).search(
          userId: userId,
          query: query,
        );
  }

  void _toggleArchetype(String archetype) {
    setState(() {
      _selectedArchetype =
          _selectedArchetype == archetype ? null : archetype;
    });

    _triggerSearch(_controller.text.trim());
  }

    void _handleAction(SearchAction action) {
    switch (action) {
      case OpenJournalAction(:final entry):
        _openJournal(entry);
        break;

      case OpenReflectionAction(:final entry):
        _openReflection(entry);
        break;

      case OpenChallengeAction(:final entry):
        _openChallenge(entry);
        break;

      case OpenQuoteAction(:final entry):
        _showQuoteDetail(entry);
        break;
    }
  }

  void _openJournal(Map<String, dynamic> entry) {
  SearchEntryDetailDialog.show(
    context: context,
    entry: entry,
  );
}

void _openReflection(Map<String, dynamic> entry) {
  SearchEntryDetailDialog.show(
    context: context,
    entry: entry,
  );
}

void _openChallenge(Map<String, dynamic> entry) {
  ChallengeDetailSheet.show(
    context: context, 
    entry: entry,
);
}

void _showQuoteDetail(Map<String, dynamic> entry) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Cita'),
      content: Text(entry['title'] ?? ''),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
   final state = ref.watch(searchControllerProvider).asData?.value ?? const SearchState();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Diarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _controller.clear();
              ref.read(searchControllerProvider.notifier).clear();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          /// SEARCH BAR
          SearchBar(controller: _controller),

          ///todo crear enum para FILTER CHIPS
          ArchetypeFilterChips(
             archetypes: const [
                  'The Mask',
                  'The Mirror',
                  'The Moon',
                  'The Shadow',
                ],
            selected: _selectedArchetype,
            onSelected: _toggleArchetype,
          ),

          const SizedBox(height: 8),

          /// BODY
          Expanded(
            child: _buildBody(state),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(SearchState state) {
    if (state.isLoading) {
      return const SearchLoadingView();
    }

    if (state.error != null) {
      return SearchEmptyState(
        message: state.error!,
        helperMessage: state.error.toString(),
      );
    }

    if (state.results.isEmpty) {
      return const SearchEmptyState(
        message: "No hay nada por aquí.",
        helperMessage: 'Busca por emociones, arquetipos o recuerdos para comenzar',
      );
    }

    return SearchResultsList(
      results: state.results,
      onAction: _handleAction,
    );
  }
}