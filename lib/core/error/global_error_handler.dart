import 'package:flutter/material.dart';
import '../logging/log_service.dart';

class GlobalErrorHandler {
  static void init() {
    FlutterError.onError = (FlutterErrorDetails details) {
      LogService.instance.error(
        'FlutterError capturado',
        error: details.exceptionAsString(),
        stackTrace: details.stack,
      );

      FlutterError.presentError(details);
    };
  }

  static bool handleAsyncError(Object error, StackTrace stackTrace) {
    LogService.instance.error(
      'Error asíncrono capturado',
      error: error,
      stackTrace: stackTrace,
    );
    return true;
  }
}