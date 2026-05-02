import 'package:alma_diary/core/logging/log_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:alma_diary/core/navigation/alma_navigation_router.dart';
import "supabase_service.dart";

/// =====================================================
/// FCM SERVICE - HANDLE PUSH NOTIFICATIONS
/// =====================================================
class FcmService {
  FcmService._();

  static final FcmService instance = FcmService._();


  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  /// INIT ENTRY POINT
  Future<void> init() async {
    await _initLocalNotifications();
    _setupForegroundListener();
    _setupBackgroundTapListener();
  }

 Future<void> registerDevice(String userId) async {
    final messaging = FirebaseMessaging.instance;
    final _client = SupabaseService.instance.client;

    //  NO BLOQUEAR FLOW CRÍTICO
    messaging.requestPermission().then((_) {
      LogService.instance.info(" Permission request done");
    });

    final token = await messaging.getToken();
    if (token == null) return;

    final existing = await _client
        .from('user_devices')
        .select('fcm_token')
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null && existing['fcm_token'] == token) {
      return;
    }

    await _client.from('user_devices').upsert({
      'user_id': userId,
      'fcm_token': token,
      'platform': 'flutter',
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
  // =====================================================
  // 2. LOCAL NOTIFICATIONS SETUP
  // =====================================================
  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const ios = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _local.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        _handleNotificationTap(response.payload);
      },
    );
  }

  // =====================================================
  // 3. FOREGROUND LISTENER (APP OPEN)
  // =====================================================
  void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final data = message.data;

      if (notification == null) return;

      _showLocalNotification(
        title: notification.title ?? '',
        body: notification.body ?? '',
        payload: data['route'],
      );
    });
  }

  // =====================================================
  // 4. BACKGROUND TAP (APP CLOSED → OPEN)
  // =====================================================
  void _setupBackgroundTapListener() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final route = message.data['route'];
      _handleNotificationTap(route);
    });
  }

  // =====================================================
  // 5. SHOW LOCAL NOTIFICATION
  // =====================================================
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'alma_channel',
      'Alma Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // =====================================================
  // 6. ROUTING LOGIC
  // =====================================================
  void _handleNotificationTap(String? route) {
    if (route == null) return;

    /// navigator global o controller
    AlmaNavigationRouter.navigate(route);
  }
}