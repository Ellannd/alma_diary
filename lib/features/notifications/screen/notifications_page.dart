import 'package:alma_diary/features/notifications/domain/notification_action_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alma_diary/models/alma_notification.dart';

import 'package:alma_diary/state/notifications/notifications_controller.dart';

import '../widgets/notification_header.dart';
import '../widgets/notification_list.dart';
import '../widgets/notification_empty_state.dart';
import '../widgets/notification_loading.dart';

import 'package:alma_diary/design_system/tokens/alma_colors.dart';
import 'package:alma_diary/design_system/tokens/alma_spacing.dart';


class NotificationsPage extends ConsumerStatefulWidget {
  final Function(String route)? onNavigate;

  const NotificationsPage({
    super.key,
    this.onNavigate,
  });

  @override
  ConsumerState<NotificationsPage> createState() =>
      _NotificationsPageState();
}

class _NotificationsPageState
    extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await ref
          .read(notificationControllerProvider.notifier)
          .ensureLoaded();
    });
  }

  Future<void> _refresh() async {
    await ref
        .read(notificationControllerProvider.notifier)
        .load();
  }

   Future<void> _markAll(String? userId) async {
    if (userId == null) return;
    await ref.read(notificationControllerProvider.notifier).markAllAsRead(userId);
  }

Future<void> _handleNotificationTap(
  AlmaNotification notification,
) async {
  final controller = ref.read(notificationControllerProvider.notifier);
  await controller.markAsRead(notification.id);

  if (mounted) {
    NotificationActionMapper.navigate(context, notification);
  }
}


  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(notificationControllerProvider);

    final isDark =
        Theme.of(context).brightness ==
        Brightness.dark;

    return Scaffold(
      backgroundColor:
          AlmaColors.background(isDark),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,

          child: Column(
            children: [
              // =========================
              // HEADER
              // =========================
              NotificationHeader(
                onRefresh: _refresh,
                onMarkAllRead: state.userId == null 
                  ? null 
                  : () => _markAll(state.userId),
              ),

              // =========================
              // CONTENT
              // =========================
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 250,
                  ),

                  child: state.isLoading
                      ? const NotificationLoading()

                      : state.notifications.isEmpty
                          ? const NotificationEmptyState()

                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal:
                                    AlmaSpacing.lg,
                              ),

                              child: NotificationList(
                                notifications:
                                    state.notifications,

                                onTap:
                                    _handleNotificationTap,

                              ),
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}