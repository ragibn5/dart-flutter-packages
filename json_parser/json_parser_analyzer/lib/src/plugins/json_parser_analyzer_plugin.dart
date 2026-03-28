import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:json_parser_analyzer/src/rules/json_parser_requirement_rule/json_parser_requirement_rule.dart';

class JsonParserAnalyzerPlugin extends Plugin {
  final SessionDataManager _sessionDataManager;

  JsonParserAnalyzerPlugin(this._sessionDataManager);

  @override
  String get name => '$JsonParserAnalyzerPlugin';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(JsonParserRequirementRule(_sessionDataManager));
  }
}
