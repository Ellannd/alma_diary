import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:alma_diary/core/logging/log_context.dart';
import 'package:alma_diary/core/logging/log_service.dart';

class AuthAnalytics {
  static Future<void> onAuthSuccess(String userId) async {
    LogContext.instance.setUser(userId);
    await FirebaseCrashlytics.instance.setUserIdentifier(userId);
    await FirebaseAnalytics.instance.setUserId(id: userId);
    LogService.instance.info(
      'auth.session_identified',
      context: {'user_id': userId},
    );
  }

  static Future<void> onAuthSignOut() async {
    LogContext.instance.setUser('');
    await FirebaseCrashlytics.instance.setUserIdentifier('');
    await FirebaseAnalytics.instance.setUserId(id: null);
    LogContext.instance.newSession();
    LogService.instance.info('auth.session_cleared');
  }
}