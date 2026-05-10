
import 'package:alma_diary/features/profile/data/profile_repository.dart';
import 'package:alma_diary/state/onboarding/onboarding_controller.dart';

import 'package:flutter/material.dart';
import 'features/dashboard/alma_theme.dart';
import 'features/auth/auth_gate.dart';
import 'features/journal/alma_journal.dart';
import 'features/profile/profile_page.dart';

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

      theme: isDark ? AlmaTheme.dark : AlmaTheme.light,

      initialRoute: '/',

      routes: {
        '/': (context) => const AuthGate(),
        '/journal': (context) => const AlmaJournal(),
        '/profile': (context) => const ProfilePage(),
      },

      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const AuthGate(),
        );
      },

      navigatorObservers: [
        AppNavigatorObserver(),
      ],
    ),
  );
}
}