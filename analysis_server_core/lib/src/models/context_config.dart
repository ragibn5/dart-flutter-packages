import 'package:analysis_server_core/src/models/log_config.dart';
import 'package:analysis_server_core/src/models/mappable.dart';
import 'package:analysis_server_core/src/models/package_info.dart';
import 'package:analysis_server_core/src/models/scan_config.dart';

abstract class ContextConfig implements Mappable {
  /// Information about the defining package
  final PackageInfo packageInfo;

  /// The configuration for logging.
  final LogConfig logConfig;

  /// The configuration for global scanning scope.
  final ScanConfig scanConfig;

  ContextConfig({
    required this.packageInfo,
    required this.logConfig,
    this.scanConfig = const ScanConfig(),
  });
}
