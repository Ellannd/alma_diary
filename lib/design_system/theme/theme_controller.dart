import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_controller.g.dart';

@riverpod
class ThemeController extends _$ThemeController {
  @override
  bool build() {
    return true; // dark mode default
  }

  void toggleTheme() {
    state = !state;
  }

  void setDarkMode(bool value) {
    state = value;
  }
}