import 'package:firebase_analytics/firebase_analytics.dart';

class AlmaAnalytics {
  static final _analytics = FirebaseAnalytics.instance;

  static Future<void> journalEntryCreated({
    required String archetype,
    required String sentiment,
  }) => _analytics.logEvent(
    name: 'journal_entry_created',
    parameters: {'archetype': archetype, 'sentiment': sentiment},
  );

  static Future<void> onboardingCompleted() =>
      _analytics.logEvent(name: 'onboarding_completed');

  static Future<void> challengeStarted({required String challengeId}) =>
      _analytics.logEvent(
        name: 'challenge_started',
        parameters: {'challenge_id': challengeId},
      );

  static Future<void> searchPerformed({required String query}) =>
      _analytics.logEvent(
        name: 'search_performed',
        parameters: {'query_length': query.length},
      );
}