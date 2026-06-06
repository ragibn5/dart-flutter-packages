import 'package:app_logger/src/app_logger.dart';
import 'package:app_logger/src/app_logger_impl.dart';
import 'package:dlogger/dlogger.dart';

class AppLoggerFactory {
  const AppLoggerFactory();

  AppLogger create({
    required Map<String, Logger> loggers,
    List<LogFilter> filters = const [],
  }) => AppLoggerImpl(filters, loggers);
}
