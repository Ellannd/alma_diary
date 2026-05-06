import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:alma_diary/state/providers/theme_provider.dart";

class ThemeController extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    return const ThemeState(isDarkMode: true);
  }

  bool get isDarkMode => state.isDarkMode;

  void setTheme(bool value) {
    state = state.copyWith(isDarkMode: value);
  }

  void toggle() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }
}