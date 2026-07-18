import 'package:loghub/src/models/log_data.dart';

abstract interface class Logger {
  /// Logs the given data.
  void log(LogData data);
}
