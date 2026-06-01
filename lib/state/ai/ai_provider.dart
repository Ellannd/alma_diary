import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alma_diary/ai/analysis/ai_services_impl.dart';
import 'package:alma_diary/ai/analysis/router/model_router.dart';
import 'package:alma_diary/ai/analysis/providers/huggingface_provider.dart';
import 'package:alma_diary/ai/analysis/providers/mock_provider.dart';


final aiServiceProvider = Provider<AIServiceImpl>((ref) {
  return AIServiceImpl(
    router: ModelRouter(
      mock: MockProvider(),
      huggingface: HuggingFaceProvider(
      ),
    ),
  );
});