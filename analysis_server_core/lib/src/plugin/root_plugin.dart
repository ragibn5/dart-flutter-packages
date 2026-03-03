import 'package:analysis_server_core/src/services/session/session_data_manager.dart';
import 'package:analysis_server_plugin/plugin.dart';

abstract class RootPlugin extends Plugin {
  final SessionDataManager sessionDataManager;

  RootPlugin(this.sessionDataManager);
}
