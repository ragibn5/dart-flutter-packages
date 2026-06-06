import 'dart:async';

import 'package:initializable/initializable.dart';
import 'package:meta/meta.dart';

abstract class CrashlyticsService implements Initializable {
  const CrashlyticsService();

  @mustCallSuper
  @override
  FutureOr<void> initialize() {}

  Future<void> setSessionData(String userId, {required bool collectionEnabled});

  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    dynamic reason,
    bool? printDetails,
    bool fatal = false,
  });
}
