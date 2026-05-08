import 'package:equatable/equatable.dart';
import 'package:alma_diary/core/logging/log_entry.dart';

enum LogSortOrder {
  newestFirst,
  oldestFirst,
}

class LogViewerState extends Equatable {
  final String query;
  final LogLevel? level;
  final LogSortOrder sortOrder;

  const LogViewerState({
    required this.query,
    required this.level,
    required this.sortOrder,
  });

  factory LogViewerState.initial() {
    return const LogViewerState(
      query: '',
      level: null,
      sortOrder: LogSortOrder.newestFirst,
    );
  }

  LogViewerState copyWith({
    String? query,
    LogLevel? level,
    LogSortOrder? sortOrder,
    bool clearLevel = false,
  }) {
    return LogViewerState(
      query: query ?? this.query,
      level: clearLevel ? null : (level ?? this.level),
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [
        query,
        level,
        sortOrder,
      ];
}