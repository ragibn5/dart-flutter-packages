import 'package:analysis_server_core/src/models/context_config.dart';
import 'package:analysis_server_core/src/services/logger/session_logger.dart';

class SessionData {
  final SessionLogger logger;
  final ContextConfig config;

  const SessionData({required this.logger, required this.config});
}
