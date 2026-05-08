import 'package:flutter/material.dart';
import '../domain/log_filter.dart';

class LogLevelFilterBar extends StatelessWidget {
  final LogLevelFilter selected;
  final ValueChanged<LogLevelFilter> onChanged;

  const LogLevelFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: LogLevelFilter.values.map((level) {
        final isSelected = level == selected;

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(_label(level)),
            selected: isSelected,
            onSelected: (_) => onChanged(level),
          ),
        );
      }).toList(),
    );
  }

  String _label(LogLevelFilter level) {
    switch (level) {
      case LogLevelFilter.all:
        return 'All';
      case LogLevelFilter.info:
        return 'Info';
      case LogLevelFilter.warning:
        return 'Warn';
      case LogLevelFilter.error:
        return 'Error';
      case LogLevelFilter.fatal:
        return "Fatal";
      case LogLevelFilter.debug:
        return "Debug";
    }
  }
  
}

