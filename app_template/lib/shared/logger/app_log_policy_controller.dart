import 'package:app_template/shared/logger/app_log_level.dart';
import 'package:app_template/shared/logger/app_logger_id.dart';

abstract interface class AppLogPolicyController {
  void blockTag(String tag);

  void unblockTag(String tag);

  void blockLevel(AppLogLevel level);

  void unblockLevel(AppLogLevel level);

  void blockLogger(AppLoggerId loggerId);

  void unblockLogger(AppLoggerId loggerId);
}
