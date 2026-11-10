import 'package:crashlykit/src/crashlytics_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class FirebaseCrashlyticsService extends CrashlyticsService {
  final FirebaseCrashlytics _crashlytics;

  FirebaseCrashlyticsService(this._crashlytics);

  @override
  Future<void> initialize() async {
    await super.initialize();

    FlutterError.onError = _crashlytics.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Note:
  /// Crashlytics takes only a string, so `null` clears it with an empty one.
  @override
  Future<void> setUserId(String? userId) {
    return _crashlytics.setUserIdentifier(userId ?? '');
  }

  /// Note:
  /// Turning it off also deletes the reports kept on the device while it was
  /// off, so they're never sent later.
  @override
  Future<void> setCollectionEnabled({required bool enabled}) async {
    await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
    if (!enabled) {
      await _crashlytics.deleteUnsentReports();
    }
  }

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    dynamic reason,
    bool? printDetails,
    bool fatal = false,
  }) {
    return _crashlytics.recordError(
      exception,
      stackTrace,
      reason: reason,
      printDetails: printDetails,
      fatal: fatal,
    );
  }
}
