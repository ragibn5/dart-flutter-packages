import 'package:app_template/shared/analytics/analytics_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@Singleton(as: AnalyticsService)
class FirebaseAnalyticsService implements AnalyticsService {
  final FirebaseAnalytics _firebaseAnalytics;

  FirebaseAnalyticsService() : this._(FirebaseAnalytics.instance);

  FirebaseAnalyticsService._(this._firebaseAnalytics);

  @visibleForTesting
  FirebaseAnalyticsService.test(FirebaseAnalytics firebaseAnalytics)
    : this._(firebaseAnalytics);

  @override
  Future<void> initialize() async {}

  @override
  Future<void> setSessionData(String userId, {required bool enabled}) async {
    await _firebaseAnalytics.setUserId(id: userId);
    await _firebaseAnalytics.setAnalyticsCollectionEnabled(enabled);
  }

  @override
  Future<void> setUserProperty({required String name, required String value}) {
    return _firebaseAnalytics.setUserProperty(name: name, value: value);
  }

  @override
  Future<void> logEvent(String name, [Map<String, Object>? params]) {
    return _firebaseAnalytics.logEvent(name: name, parameters: params);
  }
}
