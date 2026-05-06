import "package:flutter_riverpod/flutter_riverpod.dart";
import "theme_state.dart";

final themeProvider =
    NotifierProvider<ThemeController, ThemeState>(
  ThemeController.new,
);

class ThemeController extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    return const ThemeState(isDarkMode: true);
  }

  void setTheme(bool value) {
    state = state.copyWith(isDarkMode: value);
  }

  void toggle() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }
}