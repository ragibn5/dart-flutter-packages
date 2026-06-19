// ignore_for_file: cascade_invocations

import 'package:analytics/analytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() {
  final analytics = FirebaseAnalyticsService(FirebaseAnalytics.instance);

  analytics.setSessionData('user-123', collectionEnabled: true);
  analytics.logEvent('login', {'method': 'email'});
}
