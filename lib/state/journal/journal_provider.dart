import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alma_diary/features/journal/data/journal_service.dart';
import 'package:alma_diary/core/logging/log_service.dart';

import 'package:alma_diary/ai/analysis/ai_services_impl.dart';
import 'package:alma_diary/ai/analysis/providers/gemini_provider.dart';
import 'package:alma_diary/ai/analysis/providers/huggingface_provider.dart';
import 'package:alma_diary/ai/analysis/providers/mock_provider.dart';
import 'package:alma_diary/ai/analysis/router/model_router.dart';
import "package:alma_diary/state/journal/journal_state.dart";
import "package:alma_diary/state/journal/journal_controller.dart";

import 'package:flutter_dotenv/flutter_dotenv.dart';

/// =========================
/// MODEL
/// =========================
class JournalEntryModel {
  final String id;
  final String content;
  final String reflection;
  final String sentiment;
  final double sentimentScore;
  final String archetype;
  final DateTime createdAt;
  final DateTime? updatedAt;

  JournalEntryModel({
    required this.id,
    required this.content,
    required this.reflection,
    required this.sentiment,
    required this.sentimentScore,
    required this.archetype,
    required this.createdAt,
    this.updatedAt,
  });

  factory JournalEntryModel.fromMap(Map<String, dynamic> map) {
    return JournalEntryModel(
      id: map['id'] ?? '',
      content: map['content_decrypted'] ?? map['content_encrypted'] ?? '',
      reflection: map['analysis_decrypted'] ?? map['analysis_encrypted'] ?? '',
      sentiment: map['sentiment'] ?? 'neutral',
      sentimentScore: (map['sentiment_score'] ?? 0.5).toDouble(),
      archetype: map['archetype'] ?? 'The Mirror',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }
}



/// =========================
/// PROVIDERS
/// =========================
final journalServiceProvider = Provider<JournalService>((ref) {
  return JournalService.instance;
});

final aiServiceProvider = Provider<AIServiceImpl>((ref) {
  return AIServiceImpl(
    router: ModelRouter(
      mock: MockProvider(),
      huggingface: HuggingFaceProvider(
        apiKey: dotenv.get('HF_API_KEY'),
      ),
      gemini: GeminiProvider(
        apiKey: dotenv.get('GEMINI_API_KEY'),
      ),
    ),
  );
});

final journalControllerProvider =
    NotifierProvider<JournalController, JournalState>(
  JournalController.new,
);


 