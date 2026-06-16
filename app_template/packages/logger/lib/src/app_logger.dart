/// Abstract interface for application-level logging.
///
/// Provides per-level convenience methods instead of a generic `log` call.
abstract class AppLogger {
  void logDebug({
    required String tag,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  });

  void logInfo({
    required String tag,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  });

  void logWarning({
    required String tag,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  });

  void logError({
    required String tag,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  });
}
