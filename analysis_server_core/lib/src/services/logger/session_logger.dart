import 'package:dlogger/dlogger.dart';
import 'package:meta/meta.dart';

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

class SessionLoggerImpl implements SessionLogger {
  final CompositeLogger _compositeLogger;

  var _enabled = true;
  final _allowedLevels = SessionLogLevel.values.toSet();

  SessionLoggerImpl(Map<String, Logger> loggers)
    : this._(CompositeLogger(loggers.map(MapEntry.new), []));

  @visibleForTesting
  SessionLoggerImpl.test(CompositeLogger compositeLogger)
    : this._(compositeLogger);

  SessionLoggerImpl._(this._compositeLogger);

  @override
  bool get enabled => _enabled;

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
