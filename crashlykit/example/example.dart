// ignore_for_file: cascade_invocations

import 'package:crashlykit/crashlykit.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() {
  // Create an impl from FirebaseCrashlytics
  final CrashlyticsService crashlytics = FirebaseCrashlyticsService(
    FirebaseCrashlytics.instance,
  );

  // Report only once the user agrees.
  crashlytics.setCollectionEnabled(enabled: true);
  crashlytics.setUserId('user-123');

  try {
    throw Exception('Something went wrong');
  } catch (e, s) {
    crashlytics.recordError(e, s, fatal: true);
  }
}
