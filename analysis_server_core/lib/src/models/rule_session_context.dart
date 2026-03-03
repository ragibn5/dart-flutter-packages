import 'package:analysis_server_core/src/models/context_config.dart';
import 'package:analysis_server_core/src/services/logger/session_logger.dart';

class RuleSessionContext<T extends ContextConfig> {
  final T config;
  final SessionLogger logger;

  const RuleSessionContext({required this.config, required this.logger});
}
