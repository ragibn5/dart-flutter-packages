import 'package:app_template/core/contracts/initializable.dart';
import 'package:flutter/foundation.dart';

abstract interface class CrashlyticsService implements Initializable {
  Future<void> setSessionData(String userId, {required bool enabled});

  Future<void> log(String message);

  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    dynamic reason,
    bool? printDetails,
    bool fatal = false,
  });

  Future<void> recordFlutterError(
    FlutterErrorDetails flutterError, {
    bool fatal = false,
  });
}
