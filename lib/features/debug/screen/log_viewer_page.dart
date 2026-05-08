import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alma_diary/state/debug/logging_controller.dart';
import 'package:alma_diary/state/debug/log_viewer_state.dart';
import "package:alma_diary/features/debug/widgets/log_tile.dart";

class LogViewerPage extends ConsumerStatefulWidget {
  const LogViewerPage({super.key});

  @override
  ConsumerState<LogViewerPage> createState() => _LogViewerPageState();
}

class _LogViewerPageState extends ConsumerState<LogViewerPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(logViewerControllerProvider.notifier).loadLogs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(logViewerControllerProvider);
    final controller = ref.read(logViewerControllerProvider.notifier);

    final logs = controller.filteredLogs;

    final isNewestFirst =
        state.sortOrder == LogSortOrder.newestFirst;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev Console'),
        actions: [
          IconButton(
            icon: Icon(
              isNewestFirst
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
            ),
            onPressed: () {
              controller.setSortOrder(
                isNewestFirst
                    ? LogSortOrder.oldestFirst
                    : LogSortOrder.newestFirst,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: controller.clearLogs,
          ),
        ],
      ),

      body: Column(
        children: [
          // =========================
          // SEARCH
          // =========================
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: controller.setQuery,
              decoration: const InputDecoration(
                hintText: 'Search logs...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          // =========================
          // LIST
          // =========================
          Expanded(
            child: logs.isEmpty
                ? const Center(child: Text('No logs yet'))
                : ListView.builder(
                    reverse: state.sortOrder ==
                        LogSortOrder.newestFirst,
                    itemCount: logs.length,
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      return LogTile(log: log);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}