import 'package:flutter/material.dart';
import 'package:alma_diary/features/journal/data/journal_service.dart';
import 'package:alma_diary/features/reflections/entry_reflection_detail.dart';

/// AlmaJournal - UI WIDGET
/// Uses JournalService for orchestration.
/// Focuses purely on UI - no business logic.
class AlmaJournal extends StatefulWidget {
  const AlmaJournal({super.key});

  @override
  State<AlmaJournal> createState() => _AlmaJournalState();
}

class _AlmaJournalState extends State<AlmaJournal> {
  final TextEditingController _controller = TextEditingController();
  final JournalService _service = JournalService.instance;
  
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El texto no puede estar vacío.')),
      );
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

try {
      // This method calls Gemini analysis + saves entry
      final entryId = await _service.createEntryWithAnalysis(
        content: text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrada guardada')),
      );

      _controller.clear();

      // Navigate to reflection detail
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => EntryReflectionDetail(
            entryId: entryId,
            passphrase: 'alma_biometric_pass',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error al guardar la entrada';
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
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

// Show shimmer while saving (includes analyzing)
            if (_saving) _buildShimmer(),

            // Show error if any
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            const SizedBox(height: 16),

            // Save button
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
