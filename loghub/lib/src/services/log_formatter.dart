import 'package:loghub/src/models/log_data.dart';

/// A formatter to build a formatted output message from the [LogData] entry.
abstract interface class LogFormatter {
  /// Builds a formatted output message from the [LogData] entry.
  ///
  /// - [data] The [LogData] entry.
  ///
  /// Returns the formatted output message.
  String format(LogData data);
}
