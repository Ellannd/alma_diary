import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  light,
  dark,
}

final themeControllerProvider =
    NotifierProvider<ThemeController, AppThemeMode>(
  ThemeController.new,
);

class ThemeController extends Notifier<AppThemeMode> {
  //todo deberia moverse a lib/core/storage/storage_keys.dart
  static const _key = 'theme_mode';

  @override
  AppThemeMode build() {
    _loadTheme();
    return AppThemeMode.light; // default
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);

    if (value == 'dark') {
      state = AppThemeMode.dark;
    } else {
      state = AppThemeMode.light;
    }
  }

  Future<void> toggleTheme() async {
    final newTheme =
        state == AppThemeMode.dark
            ? AppThemeMode.light
            : AppThemeMode.dark;

    state = newTheme;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      newTheme == AppThemeMode.dark ? 'dark' : 'light',
    );
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      mode == AppThemeMode.dark ? 'dark' : 'light',
    );
  }
}