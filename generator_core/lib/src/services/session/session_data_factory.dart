import 'dart:io';

import 'package:build/build.dart';
import 'package:dlogger/dlogger.dart';
import 'package:generator_core/src/models/session_data.dart';
import 'package:generator_core/src/services/config/context_config_loader.dart';
import 'package:generator_core/src/services/logger/session_logger.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

abstract interface class SessionDataFactory {
  /// Create a [SessionData] instance for the given [BuildStep] instance.
  Future<SessionData> createSessionData(BuildStep buildStep);
}

class SessionDataFactoryImpl implements SessionDataFactory {
  final ContextConfigLoader _configLoader;

  SessionDataFactoryImpl(this._configLoader);

  @override
  Future<SessionData> createSessionData(BuildStep buildStep) async {
    final config = await _configLoader.loadConfig(buildStep);
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
