import 'package:equatable/equatable.dart';
import "package:alma_diary/core/logging/log_entry.dart";

enum LogSortOrder {
  newestFirst,
  oldestFirst,
}

enum LogLevelFilter {
  all,
  info,
  warning,
  error,
  fatal,
  debug,
}

class LogFilter extends Equatable {
  final LogLevel? level; // null = todos
  final String query; // búsqueda texto
  final LogSortOrder order;
  final bool autoScroll;

  const LogFilter({
    this.level,
    this.query = '',
    this.order = LogSortOrder.newestFirst,
    this.autoScroll = true,
  });

  LogFilter copyWith({
    LogLevel? level,
    String? query,
    LogSortOrder? order,
    bool? autoScroll,
    bool clearLevel = false,
  }) {
    return LogFilter(
      level: clearLevel ? null : (level ?? this.level),
      query: query ?? this.query,
      order: order ?? this.order,
      autoScroll: autoScroll ?? this.autoScroll,
    );
  }

  bool matches(LogEntry log) {
    final matchesLevel =
        level == null || level == log.level;

    final matchesQuery =
        query.isEmpty ||
        log.message.toLowerCase().contains(query.toLowerCase());

    return matchesLevel && matchesQuery;
  }

  List<LogEntry> apply(List<LogEntry> logs) {
    final filtered = logs.where(matches);

    final list = filtered.toList();

    switch (order) {
      case LogSortOrder.newestFirst:
        return list.reversed.toList();
      case LogSortOrder.oldestFirst:
        return list;
    }
  }

  bool get hasFilters =>
    level != null || query.isNotEmpty;

  @override
  List<Object?> get props => [
        level,
        query,
        order,
        autoScroll,
      ];
}

extension LogLevelFilterX on LogLevelFilter {
  bool matches(LogLevel level) {
    return switch (this) {
      LogLevelFilter.all => true,
      LogLevelFilter.debug => level == LogLevel.debug,
      LogLevelFilter.info => level == LogLevel.info,
      LogLevelFilter.warning => level == LogLevel.warning,
      LogLevelFilter.error => level == LogLevel.error,
      LogLevelFilter.fatal => level == LogLevel.fatal,
    };
  }
}