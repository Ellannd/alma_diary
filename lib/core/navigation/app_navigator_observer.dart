import 'package:flutter/widgets.dart';
import 'package:alma_diary/core/logging/log_context.dart';
import 'package:alma_diary/core/logging/log_service.dart';

class AppNavigatorObserver extends NavigatorObserver {
  void _track(String? name) {
    final screen = name ?? 'unknown';

    LogContext.instance.setScreen(screen);
    LogContext.instance.addBreadcrumb('Navigate → $screen');

    LogService.instance.debug('[NAV] $screen');
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _track(route.settings.name);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _track(previousRoute?.settings.name);
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _track(newRoute?.settings.name);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}