
import 'package:alma_diary/features/profile/data/profile_repository.dart';
import 'package:alma_diary/state/onboarding/onboarding_controller.dart';

import 'package:flutter/material.dart';
import 'design_system/theme/alma_theme.dart';
import 'features/auth/screen/auth_screen.dart';
import 'features/journal/screen/journal_editor_screen.dart';
import 'features/profile/presentation/screen/profile_page.dart';

import 'core/navigation/app_navigator_observer.dart';

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:alma_diary/state/theme/theme_controller.dart";


class MyApp extends ConsumerWidget {
  const MyApp({super.key});

@override
Widget build(BuildContext context, WidgetRef ref) {
  final themeState = ref.watch(themeProvider);
  final isDark = themeState.isDarkMode;

  return ProviderScope(
    overrides: [
      profileRepositoryProvider.overrideWithValue(ProfileRepository()),
    ],
    child: MaterialApp(
      title: 'Alma - Tu lugar seguro',
      debugShowCheckedModeBanner: false,

      theme: isDark ? AlmaTheme.dark() : AlmaTheme.light(),

      initialRoute: '/',

      routes: {
        '/': (context) => const AuthScreen(),
        '/journal': (context) => const JournalEditorScreen(),
        '/profile': (context) => const ProfilePage(),
      },

      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const AuthScreen(),
        );
      },

      navigatorObservers: [
        AppNavigatorObserver(),
      ],
    ),
  );
}
}