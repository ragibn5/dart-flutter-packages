enum SessionLogLevel { INFO, WARNING, ERROR }

abstract interface class SessionLogger {
  /// Whether the logger is enabled.
  bool get enabled;

  /// Enable or disable the entire logger.
  void setEnabled({required bool enabled});

  /// Enable or disable the specified log level.
  void setLevelStatus(SessionLogLevel level, {required bool enabled});

  /// Log an info message.
  void logInfo({
    required String tag,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  });

  /// Log a warning message.
  void logWarning({
    required String tag,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  });

  /// Log an error message.
  void logError({
    required String tag,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  });
}
