import 'package:app_logger/src/app_logger.dart';
import 'package:dlogger/dlogger.dart';
import 'package:meta/meta.dart';

class AppLoggerImpl implements AppLogger {
  final CompositeLogger _compositeLogger;

  AppLoggerImpl(List<LogFilter> filters, Map<String, Logger> loggers)
      : this._(CompositeLogger(loggers, filters));

  @visibleForTesting
  AppLoggerImpl.test(CompositeLogger compositeLogger) : this._(compositeLogger);

  AppLoggerImpl._(this._compositeLogger);

  @override
  void logDebug({
    required String tag,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) =>
      _log(LogLevel.DEBUG, tag, message, error, stackTrace, extras);

  @override
  void logInfo({
    required String tag,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) =>
      _log(LogLevel.INFO, tag, message, error, stackTrace, extras);

  @override
  void logWarning({
    required String tag,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) =>
      _log(LogLevel.WARNING, tag, message, error, stackTrace, extras);

  @override
  void logError({
    required String tag,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) =>
      _log(LogLevel.ERROR, tag, message, error, stackTrace, extras);

  void _log(
    LogLevel level,
    String tag,
    String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  ) {
    _compositeLogger.log(
      LogData(
        tag: tag,
        level: level,
        stamp: DateTime.now(),
        message: message,
        error: error,
        stackTrace: stackTrace,
        extras: extras,
      ),
    );
  }
}
