import 'package:analykit/src/analytics_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsService extends AnalyticsService {
  final FirebaseAnalytics _firebaseAnalytics;

  FirebaseAnalyticsService(this._firebaseAnalytics);

  @override
  Future<void> setUserId(String? userId) {
    return _firebaseAnalytics.setUserId(id: userId);
  }

  /// Note:
  /// Also sets the analytics storage consent, which Google needs to process
  /// data from users in the EEA; the ad consents are left to the app.
  @override
  Future<void> setCollectionEnabled({required bool enabled}) async {
    await _firebaseAnalytics.setAnalyticsCollectionEnabled(enabled);
    await _firebaseAnalytics.setConsent(
      analyticsStorageConsentGranted: enabled,
    );
  }

  @override
  Future<void> logEvent(String name, [Map<String, Object>? params]) {
    return _firebaseAnalytics.logEvent(name: name, parameters: params);
  }
}
