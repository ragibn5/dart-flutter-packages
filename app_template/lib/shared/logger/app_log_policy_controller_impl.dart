import 'package:app_template/shared/logger/app_log_level.dart';
import 'package:app_template/shared/logger/app_log_policy_controller.dart';
import 'package:app_template/shared/logger/app_logger_id.dart';
import 'package:dlogger/dlogger.dart';
import 'package:injectable/injectable.dart';

@Singleton(as: AppLogPolicyController)
class AppLogPolicyControllerImpl implements AppLogPolicyController {
  final LogPolicyController _policyController;

  AppLogPolicyControllerImpl(this._policyController);

  @override
  void blockTag(String tag) => _policyController.addBlockedTag(tag);

  @override
  void unblockTag(String tag) => _policyController.removeBlockedTag(tag);

  @override
  void blockLevel(AppLogLevel level) =>
      _policyController.addBlockedLevel(_toExternalLogLevel(level));

  @override
  void unblockLevel(AppLogLevel level) =>
      _policyController.removeBlockedLevel(_toExternalLogLevel(level));

  @override
  void blockLogger(AppLoggerId loggerId) =>
      _policyController.addBlockedLoggerId(loggerId.name);

  @override
  void unblockLogger(AppLoggerId loggerId) =>
      _policyController.removeBlockedLoggerId(loggerId.name);

  LogLevel _toExternalLogLevel(AppLogLevel level) {
    switch (level) {
      case .DEBUG:
        return LogLevel.DEBUG;
      case .INFO:
        return LogLevel.INFO;
      case .WARNING:
        return LogLevel.WARNING;
      case .ERROR:
        return LogLevel.ERROR;
    }
  }
}
