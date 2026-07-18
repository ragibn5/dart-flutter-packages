import 'dart:io';

import 'package:analysis_server_plugin_core/src/models/session_data.dart';
import 'package:analysis_server_plugin_core/src/services/config/context_config_loader.dart';
import 'package:analysis_server_plugin_core/src/services/logger/session_logger.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:intl/intl.dart';
import 'package:loghub/loghub.dart';
import 'package:path/path.dart' as path;

abstract interface class SessionDataFactory {
  /// Create a [SessionData] instance for the given [RuleContext] instance.
  SessionData createSessionData(RuleContext context);
}

class SessionDataFactoryImpl implements SessionDataFactory {
  final ContextConfigLoader _configLoader;

  SessionDataFactoryImpl(this._configLoader);

  @override
  SessionData createSessionData(RuleContext context) {
    final config = _configLoader.loadConfig(context);
    final logFilesRoot =
        config.logConfig.logDirectoryRelativePathFromProjectRoot;
    final logger =
        SessionLoggerImpl({
            config.packageInfo.location: FileLogger(
              logDirectory: Directory(
                path.join(config.packageInfo.location, logFilesRoot),
              ),
              fileNameBuilder: (data) =>
                  'LOG-${DateFormat('dd-MM-yyyy').format(data.stamp)}.log',
            ),
          })
          ..setEnabled(enabled: config.logConfig.enabled)
          ..setLevelStatus(
            SessionLogLevel.INFO,
            enabled: config.logConfig.allowInfoLog,
          )
          ..setLevelStatus(
            SessionLogLevel.WARNING,
            enabled: config.logConfig.allowWarningLog,
          )
          ..setLevelStatus(
            SessionLogLevel.ERROR,
            enabled: config.logConfig.allowErrorLog,
          );

    return SessionData(logger: logger, config: config);
  }
}
