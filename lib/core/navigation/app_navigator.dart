import 'package:flutter/material.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class AppNavigator {
  static NavigatorState? get _navigator =>
      navigatorKey.currentState;

  static Future<T?> pushNamed<T extends Object?>(
    String route, {
    Object? arguments,
  }) {
    return _navigator!.pushNamed<T>(
      route,
      arguments: arguments,
    );
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String route, {
    TO? result,
    Object? arguments,
  }) {
    return _navigator!.pushReplacementNamed<T, TO>(
      route,
      result: result,
      arguments: arguments,
    );
  }

  static void pop<T extends Object?>([T? result]) {
    _navigator?.pop(result);
  }
}
