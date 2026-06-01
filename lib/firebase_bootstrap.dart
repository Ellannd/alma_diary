import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

import 'core/logging/log_service.dart';

/// =========================
/// FIREBASE INIT
/// =========================

Future<void> initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

   // Crashlytics — habilitar solo en producción
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(!kDebugMode);

  // Analytics — habilitar siempre
  await FirebaseAnalytics.instance
      .setAnalyticsCollectionEnabled(true);
  //todo no fcm en web
  if(!kIsWeb){
    //FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler,);
  }

  //final messaging = FirebaseMessaging.instance;

 // await messaging.requestPermission();

  LogService.instance.info(
    'Firebase + FCM inicializado',
  );
}

/// =========================
/// BACKGROUND HANDLER
/// =========================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
