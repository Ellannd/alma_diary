import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alma_diary/ai/analysis/ai_services_impl.dart';
import 'package:alma_diary/ai/analysis/router/model_router.dart';
import 'package:alma_diary/ai/analysis/providers/gemini_provider.dart';
import 'package:alma_diary/ai/analysis/providers/huggingface_provider.dart';
import 'package:alma_diary/ai/analysis/providers/mock_provider.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

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