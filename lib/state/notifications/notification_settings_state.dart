import 'package:equatable/equatable.dart';

class NotificationSettingsState extends Equatable {
  final bool loading;
  final bool saving;

  final bool dailyReminderEnabled;

  final String? error;

  const NotificationSettingsState({
    required this.loading,
    required this.saving,
    required this.dailyReminderEnabled,
    required this.error,
  });

  factory NotificationSettingsState.initial() {
    return const NotificationSettingsState(
      loading: false,
      saving: false,
      dailyReminderEnabled: false,
      error: null,
    );
  }

  NotificationSettingsState copyWith({
    bool? loading,
    bool? saving,
    bool? dailyReminderEnabled,
    String? error,
    bool clearError = false,
  }) {
    return NotificationSettingsState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      dailyReminderEnabled:
          dailyReminderEnabled ??
              this.dailyReminderEnabled,

      error: clearError
          ? null
          : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        saving,
        dailyReminderEnabled,
        error,
      ];
}