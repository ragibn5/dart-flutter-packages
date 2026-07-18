import 'package:loghub/src/loggers/logger.dart';
import 'package:loghub/src/models/log_data.dart';
import 'package:loghub/src/services/log_filter.dart';
import 'package:meta/meta.dart';

/// A [Logger] that logs to multiple other loggers (of same base type).
class CompositeLogger implements Logger {
  /// {@template field_filters}
  /// A list of filters to apply to the log data before logging.
  /// The filters are applied in the order they are provided, and can also be
  /// used as interceptors.
  /// {@endtemplate}
  final List<LogFilter> _filters;

  /// {@template field_loggers}
  /// A map of logger IDs to their respective loggers. The IDs must be unique,
  /// otherwise the last one will be used.
  /// {@endtemplate}
  final Map<String, Logger> _loggers;

  /// Creates a new instance of type [CompositeLogger].
  /// - [_loggers]:
  ///   {@macro field_loggers}
  /// - [_filters]:
  ///   {@macro field_filters}
  CompositeLogger(this._loggers, this._filters);

  @override
  void log(LogData logData) {
    for (final loggerEntry in _loggers.entries) {
      final shouldBlock = _filters.any(
        (filter) => filter.shouldBlock(
          logData,
          loggerId: loggerEntry.key,
        ),
      );

      if (shouldBlock) {
        continue;
      }

      loggerEntry.value.log(logData);
    }
  }

  @visibleForTesting
  Map<String, Logger> get loggers => Map.unmodifiable(_loggers);

  @visibleForTesting
  List<LogFilter> get filters => List.unmodifiable(_filters);
}
