import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:alma_diary/state/theme/theme_controller.dart";
import "package:alma_diary/state/theme/theme_state.dart";

final themeProvider =
    NotifierProvider<ThemeController, ThemeState>(
  ThemeController.new,
);

