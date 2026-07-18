import 'package:loghub/src/models/log_data.dart';

/// A filter used to filter out logs.
abstract interface class LogFilter {
  /// Returns true if the log should be blocked.
  /// Otherwise, returns false.
  ///
  /// - [logData]: The log.
  /// - [loggerId]: The logger id.
  ///
  /// Returns true if the log should be blocked.
  /// Otherwise, returns false.
  bool shouldBlock(LogData logData, {required String loggerId});
}
