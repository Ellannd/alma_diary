import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:alma_diary/state/emotion/emotion_state.dart";
import "package:alma_diary/state/emotion/emotion_controller.dart";

final emotionProvider =
    NotifierProvider<EmotionController, EmotionState>(
  EmotionController.new,
);

