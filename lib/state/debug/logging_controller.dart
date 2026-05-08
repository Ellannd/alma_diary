import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'log_viewer_state.dart';

import 'package:alma_diary/core/logging/log_entry.dart';
import 'package:alma_diary/core/logging/log_service.dart';

final logViewerControllerProvider =
    NotifierProvider<LogViewerController, LogViewerState>(
  LogViewerController.new,
);

class LogViewerController extends Notifier<LogViewerState> {
  @override
  LogViewerState build() {
    return LogViewerState.initial();
  }

  // =========================
  // ACTIONS
  // =========================

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setLevel(LogLevel? level) {
    state = state.copyWith(
      level: level,
      clearLevel: level == null,
    );
  }

  void setSortOrder(LogSortOrder order) {
    state = state.copyWith(
      sortOrder: order,
    );
  }

  void clearLogs() {
    LogService.instance.clear();

    // fuerza rebuild del provider
    state = state.copyWith();
  }

  void loadLogs() {
    // reservado para futuro:
    // streams / DB / remote logging
  }

  // =========================
  // DERIVED
  // =========================

  List<LogEntry> get filteredLogs {
    final logs = LogService.instance.getFullLog();

    // =========================
    // FILTERS
    // =========================

    final filtered = logs.where((log) {
      final matchesQuery =
          state.query.isEmpty ||
          log.message
              .toLowerCase()
              .contains(state.query.toLowerCase());

      final matchesLevel =
          state.level == null ||
          log.level == state.level;

      return matchesQuery && matchesLevel;
    }).toList();

    // =========================
    // SORT
    // =========================

    switch (state.sortOrder) {
      case LogSortOrder.newestFirst:
        return filtered.reversed.toList();

      case LogSortOrder.oldestFirst:
        return filtered;
    }
  }
}