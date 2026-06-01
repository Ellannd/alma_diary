import 'package:flutter/material.dart';
import 'package:alma_diary/models/alma_notification.dart';
import 'package:alma_diary/core/navigation/app_routes.dart';

class NotificationActionMapper {

  static void navigate(
    BuildContext context,
    AlmaNotification notification,
  ) {
    // 1. Si la notificación trae una ruta explícita, úsala directamente
    if (notification.actionRoute != null &&
        notification.actionRoute!.isNotEmpty) {
      Navigator.of(context).pushNamed(notification.actionRoute!);
      return;
    }

    // 2. Fallback: inferir la ruta desde el título/subtítulo
    final route = _inferRoute(notification);
    if (route != null) {
      Navigator.of(context).pushNamed(route);
    }
  }

  static String? _inferRoute(AlmaNotification notification) {
    final text =
        '${notification.title} ${notification.subtitle}'.toLowerCase();

    if (text.contains('desafío') || text.contains('challenge') || text.contains('reto')) {
      return AppRoutes.challenges;
    }
    if (text.contains('diario') || text.contains('escribe') || text.contains('entrada') || text.contains('journal')) {
      return AppRoutes.journal;
    }
    if (text.contains('reflexión') || text.contains('reflejo') || text.contains('reflection')) {
      return AppRoutes.reflections;
    }
    if (text.contains('trayectoria') || text.contains('trajectory') || text.contains('progreso')) {
      return AppRoutes.trajectory;
    }
    if (text.contains('lectura') || text.contains('reading')) {
      return AppRoutes.readings;
    }

    if (text.contains('frase') || text.contains('quote')) {
      return AppRoutes.quotes;
    }

    return null;
  }
}