import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:json_parser_analyzer/src/rules/json_parser_requirement_rule/json_parser_requirement_rule.dart';

class JsonParserLintPlugin extends Plugin {
  final SessionDataManager _sessionDataManager;

  JsonParserLintPlugin(this._sessionDataManager);

  @override
  String get name => '$JsonParserLintPlugin';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(JsonParserRequirementRule(_sessionDataManager));
  }
}
