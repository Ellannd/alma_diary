// lib/services/fcm_service.dart

import 'dart:io' show Platform;

import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/core/navigation/alma_navigation_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'supabase_service.dart';

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  // =====================================================
  // INIT
  // =====================================================

  /// Llamar en bootstrap, después de que Firebase y Supabase estén listos.
  /// No registra el device aquí — eso se hace en [registerDevice] post-login.
  Future<void> init() async {
    await _initLocalNotifications();
    _setupForegroundListener();
    _setupBackgroundTapListener();
  }

  // =====================================================
  // REGISTER DEVICE
  // =====================================================

  /// Registra o actualiza el FCM token del usuario en Supabase.
  ///
  /// Llamar desde [AuthController._initCryptoSession] después del login,
  /// o desde cualquier punto donde [userId] esté disponible.
  ///
  /// También suscribe a [onTokenRefresh] para mantener el token actualizado
  /// si Firebase lo rota (reinstalación, token expirado, etc).
  Future<void> registerDevice(String userId) async {
    // 1. Pedir permiso y esperar la resolución antes de intentar getToken.
    //    En Android 13+ y iOS esto puede mostrar un dialog.
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      LogService.instance.info(
        'fcm.permission_denied',
        context: {'user_id': userId},
      );
      return; // Sin permiso no hay token — salir limpiamente
    }

    // 2. Obtener el token actual
    await _upsertToken(userId);

    // 3. Escuchar rotaciones futuras del token.
    //    Firebase puede rotar el token en cualquier momento — si no lo
    //    actualizamos, las notificaciones dejan de llegar silenciosamente.
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      LogService.instance.info(
        'fcm.token_refreshed',
        context: {'user_id': userId},
      );
      _upsertToken(userId, tokenOverride: newToken);
    });
  }

  // =====================================================
  // UPSERT TOKEN
  // =====================================================

  Future<void> _upsertToken(String userId, {String? tokenOverride}) async {
    final client = SupabaseService.instance.client;
    final platform = _currentPlatform();

    try {
      final token =
          tokenOverride ?? await FirebaseMessaging.instance.getToken();

      if (token == null) {
        LogService.instance.warning(
          'fcm.token_null',
          context: {'user_id': userId, 'platform': platform},
        );
        return;
      }

      // upsert con onConflict en (user_id, platform) — requiere la constraint
      // única añadida en add_user_devices_constraints.sql.
      // Si ya existe una fila para este user+platform, actualiza el token.
      // Si no existe, inserta.
      await client.from('user_devices').upsert(
        {
          'user_id': userId,
          'fcm_token': token,
          'platform': platform,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'user_id, platform',
      );

      LogService.instance.info(
        'fcm.device_registered',
        context: {'user_id': userId, 'platform': platform},
      );
    } catch (e, st) {
      // No relanzar — un fallo de registro no debe interrumpir el login
      LogService.instance.error(
        'fcm.register_failed',
        error: e,
        stackTrace: st,
        context: {'user_id': userId, 'platform': platform},
      );
    }
  }

  // =====================================================
  // DEREGISTER — llamar en logout
  // =====================================================

  /// Elimina el token del dispositivo actual de Supabase y lo invalida
  /// en Firebase. Llamar desde [AuthController.signOut] antes del
  /// clearSession() cripto.
  ///
  /// Esto evita que notificaciones de sesiones cerradas lleguen al dispositivo.
  Future<void> deregisterDevice(String userId) async {
    final client = SupabaseService.instance.client;
    final platform = _currentPlatform();

    try {
      // 1. Obtener el token actual para borrarlo de forma precisa
      final token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        await client
            .from('user_devices')
            .delete()
            .eq('user_id', userId)
            .eq('fcm_token', token);
      }

      // 2. Invalidar el token en Firebase — fuerza rotación en el próximo login
      await FirebaseMessaging.instance.deleteToken();

      LogService.instance.info(
        'fcm.device_deregistered',
        context: {'user_id': userId, 'platform': platform},
      );
    } catch (e, st) {
      // No relanzar — el logout debe completarse aunque esto falle
      LogService.instance.error(
        'fcm.deregister_failed',
        error: e,
        stackTrace: st,
        context: {'user_id': userId},
      );
    }
  }

  // =====================================================
  // LOCAL NOTIFICATIONS
  // =====================================================

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@drawable/ic_notification');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _local.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        _handleNotificationTap(response.payload);
      },
    );
  }

  // =====================================================
  // FOREGROUND LISTENER
  // =====================================================

  void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;

      _showLocalNotification(
        title: notification.title ?? '',
        body: notification.body ?? '',
        payload: message.data['route'],
      );
    });
  }

  // =====================================================
  // BACKGROUND TAP
  // =====================================================

  void _setupBackgroundTapListener() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message.data['route']);
    });
  }

  // =====================================================
  // SHOW LOCAL NOTIFICATION
  // =====================================================

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'alma_channel',
      'Alma Notifications',
      icon: '@drawable/ic_notification',
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
  // ROUTING
  // =====================================================

  void _handleNotificationTap(String? route) {
    if (route == null) return;
    AlmaNavigationRouter.navigate(route);
  }

  // =====================================================
  // HELPERS
  // =====================================================

  String _currentPlatform() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }
}