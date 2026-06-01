import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:alma_diary/state/emotion/emotion_state.dart";

final emotionProvider =
    NotifierProvider<EmotionController, EmotionState>(
  EmotionController.new,
);


class EmotionController extends Notifier<EmotionState> {
  @override
  EmotionState build() {
    return const EmotionState();
  }

  void setEmotion(String emotion, double intensity) {
    state = state.copyWith(
      currentEmotion: emotion,
      intensity: intensity,
      recentEmotions: [
        emotion,
        ...state.recentEmotions.take(10),
      ],
      lastUpdated: DateTime.now(),
    );
  }

  void reset() {
    state = const EmotionState();
  }
}