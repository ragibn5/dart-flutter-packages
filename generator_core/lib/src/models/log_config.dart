import 'package:generator_core/src/models/mappable.dart';

class LogConfig implements Mappable {
  final bool enabled;

  /// Whether to allow info level logging.
  final bool allowInfoLog;

  /// Whether to allow warning level logging.
  final bool allowWarningLog;

  /// Whether to enable error logging.
  final bool allowErrorLog;

  /// The path of the log directory, relative to the project root.
  final String logDirectoryRelativePathFromCurrentDir;

  const LogConfig({
    this.enabled = false,
    this.allowInfoLog = false,
    this.allowWarningLog = false,
    this.allowErrorLog = true,
    required this.logDirectoryRelativePathFromCurrentDir,
  });

  @override
  Map<String, dynamic> toMap() => {
    'enabled': enabled,
    'allowInfoLog': allowInfoLog,
    'allowWarningLog': allowWarningLog,
    'allowErrorLog': allowErrorLog,
    'logDirectoryRelativePathFromCurrentDir':
        logDirectoryRelativePathFromCurrentDir,
  };
}
