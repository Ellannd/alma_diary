import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';

import 'package:alma_diary/core/logging/log_service.dart';

class ErrorHandlers {
  static void init() {
    FlutterError.onError = (details) {
      LogService.instance.error(
        'Flutter Error',
        error: details.exception,
        stackTrace: details.stack,
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      LogService.instance.error(
        'Platform Error',
        error: error,
        stackTrace: stack,
      );
      return true;
    };
  }

  static void runAppGuarded(Widget app) {
    runZonedGuarded(
      () => runApp(app),
      (error, stack) {
        LogService.instance.fatal(
          'Zone Crash',
          error: error,
          stackTrace: stack,
        );
      },
    );
  }



  static void handleError(Object error, StackTrace stack) {
    LogService.instance.error(
      'Unhandled error',
      error: error,
      stackTrace: stack,
    );
  }

}