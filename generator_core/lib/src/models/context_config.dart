import 'package:generator_core/src/models/log_config.dart';
import 'package:generator_core/src/models/mappable.dart';
import 'package:generator_core/src/models/package_info.dart';

abstract class ContextConfig implements Mappable {
  /// Information about the defining package.
  final PackageInfo packageInfo;

  /// The configuration for logging.
  final LogConfig logConfig;

  const ContextConfig({required this.packageInfo, required this.logConfig});
}
