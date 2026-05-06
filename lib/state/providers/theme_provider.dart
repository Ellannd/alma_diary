import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:alma_diary/state/controllers/theme_controller.dart";

final themeProvider =
    NotifierProvider<ThemeController, ThemeState>(
  ThemeController.new,
);


class ThemeState {
  final bool isDarkMode;

  const ThemeState({
    this.isDarkMode = true,
  });

  ThemeState copyWith({
    bool? isDarkMode,
  }) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }


}