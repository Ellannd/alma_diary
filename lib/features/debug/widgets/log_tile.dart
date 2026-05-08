import "package:flutter/material.dart";

class LogTile extends StatefulWidget {
  final dynamic log;

  const LogTile({super.key, required this.log});

  @override
  State<LogTile> createState() => _LogTileState();
}

class _LogTileState extends State<LogTile> {
  bool expanded = false;

  Color _colorForLevel(String level) {
    switch (level) {
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final log = widget.log;
    final color = _colorForLevel(log.level.name);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => setState(() => expanded = !expanded),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Icon(Icons.bug_report, color: color, size: 18),
                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      log.message,
                      maxLines: expanded ? null : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  Text(
                    log.level.name.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              if (expanded) ...[
                const SizedBox(height: 8),

                Text(
                  log.timestamp.toString(),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),

                if (log.error != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    log.error.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}