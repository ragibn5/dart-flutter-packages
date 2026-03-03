import 'package:dlogger/src/loggers/logger.dart';
import 'package:dlogger/src/models/log_data.dart';
import 'package:dlogger/src/services/default_log_formatter.dart';
import 'package:dlogger/src/services/log_formatter.dart';
import 'package:meta/meta.dart';

/// A [Logger] implementation that logs messages to the console.
class ConsoleLogger implements Logger {
  /// {@template field_formatter}
  /// A formatter to format the log message.
  /// {@endtemplate}
  final LogFormatter _formatter;

  /// Create an instance of type [ConsoleLogger].
  /// - [formatter]:
  ///   {@macro field_formatter}
  ConsoleLogger({
    LogFormatter formatter = const DefaultLogFormatter(),
  }) : _formatter = formatter;

  @visibleForTesting
  ConsoleLogger.test(
    this._formatter,
  );

  @override
  void log(LogData data) => print(_formatter.format(data));
}
