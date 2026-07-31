import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:json_parser_linter/src/rules/json_parser_requirement_rule/json_parser_requirement_rule.dart';
import 'package:json_parser_linter/src/services/config/json_parser_linter_config_loader.dart';

/// The plugin entry point.
///
/// The Dart Analysis Server looks for a top-level field named `plugin`.
/// So, DO NOT change the variable name. See this doc for more information:
/// https://dart.dev/tools/analyzer-plugins.
final plugin = PluginBuilder(
  name: 'JsonParserLinterPlugin',
  configLoader: JsonParserLinterConfigLoader(),
).addLintRule(JsonParserRequirementRule.new).build();
