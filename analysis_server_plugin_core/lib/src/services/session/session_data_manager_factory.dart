import 'package:analysis_server_plugin_core/src/services/config/context_config_loader.dart';
import 'package:analysis_server_plugin_core/src/services/session/session_data_factory.dart';
import 'package:analysis_server_plugin_core/src/services/session/session_data_manager.dart';

final class SessionDataManagerFactory {
  // Never created: it only holds static members.
  const SessionDataManagerFactory._(); // coverage:ignore-line

  static SessionDataManager createNewInstance(
    ContextConfigLoader packageConfigLoader,
  ) => SessionDataManagerImpl(SessionDataFactoryImpl(packageConfigLoader));
}
