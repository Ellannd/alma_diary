import 'package:flutter/material.dart';

import 'app_routes.dart';

import "package:alma_diary/features/auth/screen/auth_screen.dart";
import 'package:alma_diary/features/journal/screen/journal_editor_screen.dart';
import 'package:alma_diary/features/profile/presentation/screen/profile_page.dart';
import 'package:alma_diary/features/search/screen/search_screen.dart';
import 'package:alma_diary/features/reflections/screen/reflections_screen.dart';
import "package:alma_diary/features/dashboard/screen/dashboard_screen.dart";
import "package:alma_diary/features/profile/settings/screen/settings_page.dart";
//todo dont hardode passphrase
class AppRouter {
  static Route<dynamic> onGenerateRoute(
    RouteSettings settings,
  ) {
    switch (settings.name) {
      case AppRoutes.auth:
        return _page(const AuthScreen());

      case AppRoutes.dashboard:
        return _page(const DashboardScreen());

      case AppRoutes.journal:
        return _page(const JournalEditorScreen());

      case AppRoutes.profile:
        return _page(const ProfilePage());

      case AppRoutes.search:
        return _page(const SearchScreen(passphrase: "alma_biometric_pass",));

      case AppRoutes.reflections:
        return _page(const AlmaReflectionsScreen());
      case AppRoutes.settings:
        return _page(const SettingsPage());

      default:
        return _page(const AuthScreen());
    }
  }

  static MaterialPageRoute _page(
    Widget child,
  ) {
    return MaterialPageRoute(
      builder: (_) => child,
    );
  }
}
