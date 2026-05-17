import 'package:alma_diary/features/challenges/screen/challenges_screen.dart';
import 'package:alma_diary/features/journal/screen/create_page.dart';
import 'package:alma_diary/features/notifications/screen/notifications_page.dart';
import 'package:alma_diary/features/quotes/screen/alma_quotes.dart';
import 'package:alma_diary/features/readings/screen/readings_page.dart';
import 'package:flutter/material.dart';

import 'app_routes.dart';

import "package:alma_diary/features/auth/screen/auth_screen.dart";
import 'package:alma_diary/features/journal/screen/journal_editor_screen.dart';
import 'package:alma_diary/features/profile/presentation/screen/profile_page.dart';
import 'package:alma_diary/features/search/screen/search_screen.dart';
import 'package:alma_diary/features/reflections/screen/reflections_screen.dart';
import 'package:alma_diary/features/reflections/screen/trajectory_screen.dart';
import "package:alma_diary/features/dashboard/screen/dashboard_screen.dart";
import "package:alma_diary/features/profile/settings/screen/settings_page.dart";
import "package:alma_diary/features/auth/screen/auth_gate.dart"; 
//todo dont hardode passphrase
class AppRouter {
  static Route<dynamic> onGenerateRoute(
    RouteSettings settings,
  ) {
    switch (settings.name) {
      case AppRoutes.auth:
        return _page(const AuthGate());

      case AppRoutes.dashboard:
        return _page(const DashboardScreen());

      case AppRoutes.journal:
        return _page(const JournalEditorScreen());

      case AppRoutes.readings:
        return _page(const ReadingsPage());

      case AppRoutes.trajectory:
        return _page(const AlmaTrajectoryScreen(passphrase:"alma_biometric_pass" ,));

      case AppRoutes.profile:
        return _page(const ProfilePage());

      case AppRoutes.search:
        return _page(const SearchScreen(passphrase: "alma_biometric_pass",));

      case AppRoutes.reflections:
        return _page(const AlmaReflectionsScreen());

      case AppRoutes.quotes:
        return _page(const AlmaQuotesScreen());
      
      case AppRoutes.notifications:
        return _page(const NotificationsPage());

      case AppRoutes.create:
        return _page(const CreatePage());
      
      case AppRoutes.challenges:
        return _page(const ChallengesPage());

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
