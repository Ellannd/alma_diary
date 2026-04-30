import 'package:flutter/material.dart';
import 'package:alma_diary/ai/analysis/gemini_analysis_service.dart' as gas;
import 'package:alma_diary/auth/alma_auth_session.dart';
import 'package:alma_diary/features/journal/journal_service.dart';
import 'package:alma_diary/features/reflections/alma_trajectory.dart';
import "package:alma_diary/core/logging/log_service.dart";

class AlmaJournal extends StatefulWidget {
  const AlmaJournal({super.key});

  @override
  State<AlmaJournal> createState() => _AlmaJournalState();
}

class _AlmaJournalState extends State<AlmaJournal> {
  final TextEditingController _controller = TextEditingController();
  final gas.GeminiAnalysisService _analysisService =
      gas.GeminiAnalysisService();

  bool _saving = false;
  bool _showShimmer = false;
  String? _reflectionPreview;

  Future<void> _saveEntry() async {
    setState(() => _saving = true);

    final auth = await AlmaAuthSession.ensureAuthenticated();
    if (!auth) {
      setState(() => _saving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Autenticación fallida.')));
      return;
    }

    final text = _controller.text.trim();

    if (text.isEmpty) {
      if (!mounted) return;
        setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El texto no puede estar vacío.')),
      );
      return;
    }

    // Defaults (IA opcional)
    String sentiment = 'neutral';
    double sentimentScore = 0.5;
    String archetype = 'The Mirror';
    String reflection = 'Tu experiencia es válida y merece atención.';

    try {
      setState(() => _showShimmer = true);

      final analysis = await _analysisService.analyzeEntry(text);

      sentiment = analysis.sentiment;
      sentimentScore = analysis.sentimentScore;
      archetype = analysis.archetype;
      reflection = analysis.reflection;
    } catch (e) {
      LogService.instance.error('journal.analysis.error: $e', context: {'entry': text});
    }

    try {
      await JournalService.instance.createEntry(
        content: text,
        sentiment: sentiment,
        sentimentScore: sentimentScore,
        archetype: archetype,
        reflection: reflection,
      );

      if (!mounted) return;

      setState(() {
        _saving = false;
        _showShimmer = false;
        _reflectionPreview = reflection;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Entrada guardada')));

      _controller.clear();
      _reflectionPreview = null;

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              const AlmaTrajectoryScreen(passphrase: 'alma_biometric_pass'),
        ),
      );
    } catch (e) {
      LogService.instance.error('journal.save.error: $e', context: {'entry': text, 'sentiment': sentiment, 'archetype': archetype});

      if (!mounted) return;

      setState(() {
        _saving = false;
        _showShimmer = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar la entrada')),
      );
    }
  }

  Widget _buildShimmer() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildReflectionBubble(String reflection) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(reflection, style: const TextStyle(color: Colors.white)),
    );
  }

@override
Widget build(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  final onSurface = colorScheme.onSurface;
  final primary = colorScheme.primary;

  return Scaffold(
    appBar: AppBar(
      title: const Text('Diario'),
    ),

    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 10,
              maxLines: null,
              style: TextStyle(
                color: onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Escribe lo que sientes...',
                hintStyle: TextStyle(
                  color: onSurface.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                filled: true,
                fillColor: Theme.of(context).cardColor.withValues(alpha: 0.3),
              ),
            ),
          ),

          if (_showShimmer) _buildShimmer(),

          if (_reflectionPreview != null)
            _buildReflectionBubble(_reflectionPreview!),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _saveEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _saving
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Text('Guardar'),
            ),
          ),
        ],
      ),
    ),
  );
}
}
