import 'package:flutter/foundation.dart';
import 'package:alma_diary/ai/engines/notifications_engine.dart';
import 'package:alma_diary/core/logging/log_service.dart';
import 'package:alma_diary/core/result/validation_result.dart';
import 'package:alma_diary/models/alma_notification.dart';
import 'package:alma_diary/services/supabase_service.dart';

/// NotificationController - SINGLE SOURCE OF TRUTH
class NotificationController extends ChangeNotifier {
  static NotificationController? _instance;

  static NotificationController get instance {
    _instance ??= NotificationController._();
    return _instance!;
  }

  final AlmaNotificationEngine _engine;
  List<AlmaNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _userId;

  List<AlmaNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  NotificationController._()
      : _engine =
            AlmaNotificationEngine(SupabaseService.instance.client) {
    LogService.instance.debug('NotificationController initialized');
  }

  void setUserId(String userId) {
    _userId = userId;
  }

  void attachUser() {
    final user = SupabaseService.instance.client.auth.currentUser;
    if (user == null) return;
    _userId = user.id;
  }

  Future<void> load() async {
    attachUser();

    if (_userId == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final data = await _engine.fetchUserNotifications(_userId!);

      _notifications =
          data.map((e) => AlmaNotification.fromMap(e)).toList();

      _unreadCount = await _engine.getUnreadCount(_userId!);
    } catch (e, st) {
      LogService.instance.error(
        'Error loading notifications',
        error: e,
        stackTrace: st,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> ensureLoaded() async {
    if (_userId == null) return;
    if (_notifications.isNotEmpty) return;
    await load();
  }

  Future<void> markAsRead(String id) async {
    try {
      LogService.instance.info(
        'Marking notification as read',
        context: {
          'component': 'NotificationController',
          'notificationId': id,
          'userId': _userId
        },
      );

      final result = await _engine.markAsRead(id);

      if (!result.isValid) {
        LogService.instance.warning(
          'markAsRead failed',
          context: {
            'component': 'NotificationController',
            'error': result.error,
          },
        );
        return;
      }

      await load();

      LogService.instance.info(
        'Notification marked as read',
        context: {
          'component': 'NotificationController',
          'notificationId': id,
          'userId': _userId
        },
      );
    } catch (e, st) {
      LogService.instance.error(
        'Error marking notification as read',
        error: e,
        stackTrace: st,
        context: {
          'component': 'NotificationController',
          'notificationId': id,
          'userId': _userId
        },
      );
    }
  }

  Future<void> handlePostLogin(String userId) async {
    _userId = userId;

    LogService.instance.info(
      'Handling post-login notification setup',
      context: {'component': 'NotificationController', 'userId': userId},
    );

    try {
      final results = await Future.wait<ValidationResult>([
        _engine.generateDailyQuote(userId),
        _engine.trackLoginEvent(userId),
        _engine.generateDailyReminder(userId),
      ]);

      for (final r in results) {
        if (!r.isValid) {
          LogService.instance.warning(
            'PostLogin step failed',
            context: {'error': r.error},
          );
        }
      }

      await load();

      LogService.instance.info(
        'Post-login notifications processed',
        context: {'component': 'NotificationController', 'userId': userId},
      );
    } catch (e, st) {
      LogService.instance.error(
        'Error in handlePostLogin',
        error: e,
        stackTrace: st,
        context: {'component': 'NotificationController', 'userId': userId},
      );
    }
  }

  Future<void> handleOnboardingCompleted(String userId) async {
    try {
      LogService.instance.info(
        'Handling onboarding completed notification',
        context: {'component': 'NotificationController', 'userId': userId},
      );

      final result = await _engine.notifyInsight(
        userId: userId,
        title: 'Bienvenido a Alma',
        message: 'Tu viaje ha comenzado',
      );

      if (!result.isValid) {
        LogService.instance.warning(
          'Onboarding notification failed',
          context: {'error': result.error},
        );
      }

      await load();

      LogService.instance.info(
        'Onboarding notification sent',
        context: {'component': 'NotificationController', 'userId': userId},
      );
    } catch (e, st) {
      LogService.instance.error(
        'Error in handleOnboardingCompleted',
        error: e,
        stackTrace: st,
        context: {'component': 'NotificationController', 'userId': userId},
      );
    }
  }

  Future<void> handleNewJournalEntry(String userId) async {
    try {
      LogService.instance.info(
        'Handling new journal entry notification',
        context: {'component': 'NotificationController', 'userId': userId},
      );

      final result = await _engine.notifyInsight(
        userId: userId,
        title: 'Nuevo registro',
        message: 'Has escrito una nueva entrada',
      );

      if (!result.isValid) {
        LogService.instance.warning(
          'Journal notification failed',
          context: {'error': result.error},
        );
      }

      await load();

      LogService.instance.info(
        'Journal entry notification sent',
        context: {'component': 'NotificationController', 'userId': userId},
      );
    } catch (e, st) {
      LogService.instance.error(
        'Error in handleNewJournalEntry',
        error: e,
        stackTrace: st,
        context: {'component': 'NotificationController', 'userId': userId},
      );
    }
  }

  Future<void> handleChallengeEvent(
    String userId,
    String title, {
    String eventType = 'started',
    int points = 0,
  }) async {
    try {
      LogService.instance.info(
        'Handling challenge event notification',
        context: {
          'component': 'NotificationController',
          'userId': userId,
          'eventType': eventType,
          'title': title,
          'points': points
        },
      );

      ValidationResult result;

      if (eventType == 'started') {
        result = await _engine.notifyChallengeStarted(
          userId: userId,
          challengeTitle: title,
        );
      } else {
        result = await _engine.notifyChallengeCompleted(
          userId: userId,
          challengeTitle: title,
          rewardPoints: points,
        );
      }

      if (!result.isValid) {
        LogService.instance.warning(
          'Challenge notification failed',
          context: {'error': result.error},
        );
        return;
      }

      await load();

      LogService.instance.info(
        'Challenge event notification processed',
        context: {
          'component': 'NotificationController',
          'userId': userId,
          'eventType': eventType
        },
      );
    } catch (e, st) {
      LogService.instance.error(
        'Error in handleChallengeEvent',
        error: e,
        stackTrace: st,
        context: {
          'component': 'NotificationController',
          'userId': userId,
          'eventType': eventType,
          'title': title
        },
      );
    }
  }

  void reset() {
    LogService.instance.info(
      'Resetting NotificationController state',
      context: {
        'component': 'NotificationController',
        'userId': _userId,
        'notificationCount': _notifications.length,
        'unreadCount': _unreadCount
      },
    );

    _notifications = [];
    _unreadCount = 0;
    _isLoading = false;
    _userId = null;
    notifyListeners();

    LogService.instance.debug(
      'NotificationController state reset complete',
      context: {'component': 'NotificationController'},
    );
  }

  Future<void> handleChallengeEventDevice(
    String userId,
    String title, {
    String eventType = 'started',
    int points = 0,
  }) async {
    try {
      if (eventType == 'started') {
        await _engine.notifyChallengeStarted(
          userId: userId,
          challengeTitle: title,
        );

        await _engine.sendPush(
          userId: userId,
          title: 'Nuevo desafío iniciado',
          body: title,
        );
      }

      if (eventType == 'completed') {
        await _engine.notifyChallengeCompleted(
          userId: userId,
          challengeTitle: title,
          rewardPoints: points,
        );

        await _engine.sendPush(
          userId: userId,
          title: 'Desafío completado 🎉',
          body: '$title (+$points pts)',
        );
      }

      await load();
    } catch (e, st) {
      LogService.instance.error(
        'push+notification failed',
        error: e,
        stackTrace: st,
      );
    }
  }
}