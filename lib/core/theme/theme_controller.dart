import 'package:flutter/material.dart';

class ThemeController {
  static final ValueNotifier<bool> _isDarkMode = ValueNotifier(true);

  // (solo lectura limpia)
  static bool get isDarkMode => _isDarkMode.value;

  //  (para UI reactiva)
  static ValueNotifier<bool> get notifier => _isDarkMode;

  // setter controlado
  static void setTheme(bool value) {
    _isDarkMode.value = value;
  }

  // opcional: toggle
  static void toggle() {
    _isDarkMode.value = !_isDarkMode.value;
  }
}