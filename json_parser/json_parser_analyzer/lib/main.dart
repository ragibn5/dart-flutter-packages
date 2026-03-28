import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:json_parser_analyzer/src/plugins/json_parser_analyzer_plugin.dart';
import 'package:json_parser_analyzer/src/services/config/json_parser_analyzer_config_loader.dart';

/// The plugin entry point.
///
/// The Dart Analysis Server looks for a top-level field named `plugin`.
/// So, DO NOT change the variable name. See this doc for more information:
/// https://dart.dev/tools/analyzer-plugins.
final plugin = JsonParserAnalyzerPlugin(
  SessionDataManagerFactory.createNewInstance(JsonParserAnalyzerConfigLoader()),
);
