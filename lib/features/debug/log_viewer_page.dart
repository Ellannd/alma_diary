import 'package:flutter/material.dart';
import "package:alma_diary/core/logging/log_service.dart";

class LogViewerPage extends StatelessWidget {
  const LogViewerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = LogService.instance.getFullLog().reversed.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Debug Logs')),
      body: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];

          return ListTile(
            title: Text(log.message),
            subtitle: Text(log.level.name),
          );
        },
      ),
    );
  }
}