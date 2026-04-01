import 'package:generator_core/src/models/context_config.dart';
import 'package:generator_core/src/services/logger/session_logger.dart';

class BuildSessionContext<T extends ContextConfig> {
  final T config;
  final SessionLogger logger;

  const BuildSessionContext({required this.config, required this.logger});
}
