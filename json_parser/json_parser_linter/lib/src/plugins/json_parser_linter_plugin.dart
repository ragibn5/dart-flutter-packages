import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:json_parser_linter/src/rules/json_parser_requirement_rule/json_parser_requirement_rule.dart';

class JsonParserLinterPlugin extends Plugin {
  final SessionDataManager _sessionDataManager;

  JsonParserLinterPlugin(this._sessionDataManager);

  @override
  String get name => '$JsonParserLinterPlugin';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(JsonParserRequirementRule(_sessionDataManager));
  }
}
