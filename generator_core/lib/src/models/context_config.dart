import 'package:generator_core/src/models/log_config.dart';
import 'package:generator_core/src/models/mappable.dart';

abstract class ContextConfig implements Mappable {
  /// The configuration for logging.
  final LogConfig logConfig;

  const ContextConfig({required this.logConfig});
}
