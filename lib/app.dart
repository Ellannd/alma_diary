import 'package:flutter/material.dart';
import "package:responsive_framework/responsive_framework.dart";
import 'design_system/theme/alma_theme.dart';
import 'features/auth/screen/auth_screen.dart';

import 'package:alma_diary/core/navigation/app_router.dart';
import 'core/navigation/app_navigator_observer.dart';

import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:alma_diary/state/theme/theme_controller.dart";


class MyApp extends ConsumerWidget {
  const MyApp({super.key});

@override
Widget build(BuildContext context, WidgetRef ref) {
  final themeState = ref.watch(themeProvider);
  final isDark = themeState.isDarkMode;

 return MaterialApp(
  title: 'Alma - Diary',
  debugShowCheckedModeBanner: false,

  theme: isDark
      ? AlmaTheme.dark()
      : AlmaTheme.light(),

  // =========================
  // RESPONSIVE FRAMEWORK
  // =========================
  builder: (context, child) {
    return ResponsiveBreakpoints.builder(
      child: child!,
      breakpoints: [
        const Breakpoint(
          start: 0,
          end: 450,
          name: PHONE,
        ),

        const Breakpoint(
          start: 451,
          end: 800,
          name: TABLET,
        ),

        const Breakpoint(
          start: 801,
          end: 1920,
          name: DESKTOP,
        ),

        const Breakpoint(
          start: 1921,
          end: 3840,
          name: '4K',
        ),
      ],
    );
  },

  initialRoute: '/',

  onGenerateRoute: AppRouter.onGenerateRoute,

  onUnknownRoute: (settings) {
    return MaterialPageRoute(
      builder: (_) => const AuthScreen(),
    );
  },

  navigatorObservers: [
    AppNavigatorObserver(),
  ],
);

  }
}