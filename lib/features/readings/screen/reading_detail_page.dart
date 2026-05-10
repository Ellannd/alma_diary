import 'package:flutter/material.dart';

class ReadingDetailPage extends StatelessWidget {
  final dynamic reading;

  const ReadingDetailPage({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    final title = reading['title'] ?? '';
    final content = reading['content'] ?? '';

    final normalized = content.replaceAll(r'\n', '\n');

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(normalized),
      ),
    );
  }
}