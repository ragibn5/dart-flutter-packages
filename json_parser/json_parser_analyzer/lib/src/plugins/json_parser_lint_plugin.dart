import 'package:analysis_server_core/analysis_server_core.dart';

class JsonParserLintPlugin extends Plugin {
  final SessionDataManager _sessionDataManager;

  JsonParserLintPlugin(this._sessionDataManager);

  @override
  String get name => '$JsonParserLintPlugin';

  @override
  void register(PluginRegistry registry) {
    throw UnimplementedError();
  }
}
