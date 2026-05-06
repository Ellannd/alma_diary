import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmotionState {
  final String currentEmotion; // "calm", "sad", "anxious", etc
  final double intensity; // 0.0 - 1.0
  final List<String> recentEmotions;
  final DateTime? lastUpdated;

  const EmotionState({
    this.currentEmotion = 'neutral',
    this.intensity = 0.5,
    this.recentEmotions = const [],
    this.lastUpdated,
  });

  EmotionState copyWith({
    String? currentEmotion,
    double? intensity,
    List<String>? recentEmotions,
    DateTime? lastUpdated,
  }) {
    return EmotionState(
      currentEmotion: currentEmotion ?? this.currentEmotion,
      intensity: intensity ?? this.intensity,
      recentEmotions: recentEmotions ?? this.recentEmotions,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

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