import 'package:analysis_server_plugin_core/src/models/mappable.dart';

class LogConfig implements Mappable {
  final bool enabled;

  /// Whether to allow info level logging.
  final bool allowInfoLog;

  /// Whether to allow warning level logging.
  final bool allowWarningLog;

  /// Whether to enable error logging.
  final bool allowErrorLog;

  /// The path of the log directory, relative to the project root.
  final String logDirectoryRelativePathFromProjectRoot;

  const LogConfig({
    this.enabled = false,
    this.allowInfoLog = false,
    this.allowWarningLog = true,
    this.allowErrorLog = true,
    required this.logDirectoryRelativePathFromProjectRoot,
  });

  @override
  Map<String, dynamic> toMap() => {
    'enabled': enabled,
    'allowInfoLog': allowInfoLog,
    'allowWarningLog': allowWarningLog,
    'allowErrorLog': allowErrorLog,
    'logDirectoryRelativePathFromProjectRoot':
        logDirectoryRelativePathFromProjectRoot,
  };
}
