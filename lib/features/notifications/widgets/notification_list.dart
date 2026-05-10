import 'package:flutter/material.dart';

import 'package:alma_diary/models/alma_notification.dart';

import 'notification_card.dart';

class NotificationList
    extends StatelessWidget {
  final List<AlmaNotification>
      notifications;

  final Future<void> Function(
    AlmaNotification notification,
  )?
      onTap;

  const NotificationList({
    super.key,
    required this.notifications,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification =
            notifications[index];

        return NotificationCard(
          notification: notification,
          onTap: () async {
            await onTap?.call(
              notification,
            );
          },
          onAction: () async {
            await onTap?.call(
              notification,
            );
          },
        );
      },
    );
  }
}