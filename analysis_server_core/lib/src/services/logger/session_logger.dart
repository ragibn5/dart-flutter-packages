import 'package:dlogger/dlogger.dart';
import 'package:meta/meta.dart';

enum SessionLogLevel { INFO, WARNING, ERROR }

abstract interface class SessionLogger {
  @visibleForTesting
  bool get enabled;

  @visibleForTesting
  Set<SessionLogLevel> get allowedLevels;

  /// Enable or disable the entire logger.
  ///
  /// **Note:**
  /// - This does not alter the enabled/disabled state of log levels.
  /// - Disabling the logger will completely disable logging.
  ///   This is the main switch. To enable/disable individual
  ///   log levels, use [setLevelStatus].
  void setEnabled({required bool enabled});

  /// Enable or disable the specified log level.
  ///
  /// **Note:**
  /// - This is a level-specific switch. To enable/disable the entire logger,
  ///   use [setEnabled].
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

class SessionLoggerImpl implements SessionLogger {
  final CompositeLogger _compositeLogger;

  bool _enabled;
  Set<SessionLogLevel> _allowedLevels;

  SessionLoggerImpl(Map<String, Logger> loggers)
    : this._(CompositeLogger(loggers.map(MapEntry.new), []), true, {
        SessionLogLevel.INFO,
        SessionLogLevel.WARNING,
        SessionLogLevel.ERROR,
      });

  @visibleForTesting
  SessionLoggerImpl.test(
    CompositeLogger compositeLogger, {
    required bool enabled,
    required Set<SessionLogLevel> allowedLevels,
  }) : this._(compositeLogger, enabled, allowedLevels);

  SessionLoggerImpl._(
    this._compositeLogger,
    this._enabled,
    this._allowedLevels,
  );

  @override
  @visibleForTesting
  bool get enabled => _enabled;

  @override
  @visibleForTesting
  Set<SessionLogLevel> get allowedLevels => Set.unmodifiable(_allowedLevels);

  @override
  void setEnabled({required bool enabled}) {
    _enabled = enabled;
  }

  @override
  void setLevelStatus(SessionLogLevel level, {required bool enabled}) {
    if (enabled) {
      _allowedLevels.add(level);
    } else {
      _allowedLevels.remove(level);
    }
  }

  @override
  void logInfo({
    required String tag,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {
    if (!_enabled || !_allowedLevels.contains(SessionLogLevel.INFO)) {
      return;
    }

    _compositeLogger.log(
      LogData(
        tag: tag,
        level: LogLevel.INFO,
        stamp: DateTime.now(),
        message: message,
        error: error,
        stackTrace: stackTrace,
        extras: extras,
      ),
    );
  }

  @override
  void logWarning({
    required String tag,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {
    if (!_enabled || !_allowedLevels.contains(SessionLogLevel.WARNING)) {
      return;
    }

    _compositeLogger.log(
      LogData(
        tag: tag,
        level: LogLevel.WARNING,
        stamp: DateTime.now(),
        message: message,
        error: error,
        stackTrace: stackTrace,
        extras: extras,
      ),
    );
  }

  @override
  void logError({
    required String tag,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {
    if (!_enabled || !_allowedLevels.contains(SessionLogLevel.ERROR)) {
      return;
    }

    _compositeLogger.log(
      LogData(
        tag: tag,
        level: LogLevel.ERROR,
        stamp: DateTime.now(),
        message: message,
        error: error,
        extras: extras,
      ),
    );
  }
}
