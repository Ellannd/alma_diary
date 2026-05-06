import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alma_diary/features/notifications/engine/notifications_engine.dart';
import "package:alma_diary/state/notifications/notifications_controller.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "package:alma_diary/state/notifications/notification_state.dart";


final notificationEngineProvider = Provider<AlmaNotificationEngine>((ref) {
  final client = Supabase.instance.client;
  return AlmaNotificationEngine(client);
});

final notificationControllerProvider =
    NotifierProvider<NotificationController, NotificationState>(
  NotificationController.new,
);