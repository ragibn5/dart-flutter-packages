import 'package:app_template/shared/logger/app_logger.dart';
import 'package:app_template/shared/logger/app_logger_id.dart';
import 'package:dlogger/dlogger.dart';
import 'package:meta/meta.dart';

class AppLoggerImpl implements AppLogger {
  final CompositeLogger _compositeLogger;

  AppLoggerImpl(List<LogFilter> filters, Map<AppLoggerId, Logger> loggers)
    : this._(
        CompositeLogger(
          loggers.map((key, value) => MapEntry(key.name, value)),
          filters,
        ),
      );

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
  }) => _compositeLogger.log(
    LogData(
      tag: tag,
      level: LogLevel.DEBUG,
      stamp: DateTime.now(),
      message: message,
      error: error,
      stackTrace: stackTrace,
      extras: extras,
    ),
  );

  @override
  void logInfo({
    required String tag,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) => _compositeLogger.log(
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

  @override
  void logWarning({
    required String tag,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) => _compositeLogger.log(
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

  @override
  void logError({
    required String tag,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) => _compositeLogger.log(
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
