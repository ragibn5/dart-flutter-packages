// ignore_for_file: cascade_invocations

import 'package:analykit/analykit.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() {
  // Create an impl from FirebaseAnalytics
  final AnalyticsService analytics = FirebaseAnalyticsService(
    FirebaseAnalytics.instance,
  );

  // Collect only once the user agrees.
  analytics.setCollectionEnabled(enabled: true);
  analytics.setUserId('user-123');
  analytics.logEvent('login', {'method': 'email'});
}
