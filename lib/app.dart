import 'package:flutter/material.dart';
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
      title: 'Alma - Tu lugar seguro',
      debugShowCheckedModeBanner: false,

      theme: isDark ? AlmaTheme.dark() : AlmaTheme.light(), 

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