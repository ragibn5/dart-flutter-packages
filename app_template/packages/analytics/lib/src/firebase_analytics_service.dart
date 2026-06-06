import 'package:analytics/src/analytics_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:meta/meta.dart';

class FirebaseAnalyticsService extends AnalyticsService {
  final FirebaseAnalytics _firebaseAnalytics;

  FirebaseAnalyticsService() : this._(FirebaseAnalytics.instance);

  FirebaseAnalyticsService._(this._firebaseAnalytics);

  @visibleForTesting
  FirebaseAnalyticsService.test(FirebaseAnalytics firebaseAnalytics)
    : this._(firebaseAnalytics);

  @override
  Future<void> setSessionData(
    String userId, {
    required bool collectionEnabled,
  }) async {
    await _firebaseAnalytics.setUserId(id: userId);
    await _firebaseAnalytics.setAnalyticsCollectionEnabled(collectionEnabled);
  }

  @override
  Future<void> logEvent(String name, [Map<String, Object>? params]) {
    return _firebaseAnalytics.logEvent(name: name, parameters: params);
  }
}
