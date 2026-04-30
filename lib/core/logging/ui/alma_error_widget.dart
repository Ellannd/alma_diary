import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alma_diary/core/logging/log_service.dart';

class AlmaErrorWidget extends StatefulWidget {
  final FlutterErrorDetails errorDetails;
  final VoidCallback? onRestart;

  const AlmaErrorWidget({
    super.key,
    required this.errorDetails,
    this.onRestart,
  });

  @override
  State<AlmaErrorWidget> createState() => _AlmaErrorWidgetState();
}

class _AlmaErrorWidgetState extends State<AlmaErrorWidget> {
  late final String log;

  @override
  void initState() {
    super.initState();

    log = LogService.instance.exportLog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B12),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 72,
                color: Color(0xFFE94560),
              ),

              const SizedBox(height: 24),

              const Text(
                'Algo salió mal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                widget.errorDetails.exceptionAsString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontFamily: 'monospace',
                ),
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      if (widget.onRestart != null) {
                        widget.onRestart!();
                      } else {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reiniciar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16213E),
                      foregroundColor: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 12),

                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: log));

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Logs copiados al portapapeles'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copiar logs'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      log,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white38,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}