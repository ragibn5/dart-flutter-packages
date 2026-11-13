import 'dart:async';

import 'package:meta/meta.dart';

abstract class CrashlyticsService {
  const CrashlyticsService();

  /// Initializes the crash reporting service.
  ///
  /// Must be called before any other methods.
  @mustCallSuper
  Future<void> initialize() async {}

  /// Associates crash reports with the given [userId]; `null` clears it,
  /// such as on sign-out.
  Future<void> setUserId(String? userId);

  /// Turns crash reporting on or off.
  ///
  /// Note:
  /// The provider remembers it across launches.
  Future<void> setCollectionEnabled({required bool enabled});

  /// Records an error with the given [exception] and [stackTrace].
  ///
  /// Optionally accepts a [reason], [printDetails] flag, and whether
  /// the error was [fatal].
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    dynamic reason,
    bool? printDetails,
    bool fatal = false,
  });
}
