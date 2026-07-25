import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_linter/src/models/clean_arch_linter_config.dart';
import 'package:clean_arch_linter/src/rules/dependency_direction_rule/dependency_direction_rule.dart';
import 'package:clean_arch_linter/src/services/config/clean_arch_linter_config_loader.dart';

/// The plugin entry point.
///
/// The Dart Analysis Server looks for a top-level field named `plugin`.
/// So, DO NOT change the variable name. See this doc for more information:
/// https://dart.dev/tools/analyzer-plugins.
final plugin = PluginBuilder<CleanArchLinterConfig>(
  name: 'CleanArchLinterPlugin',
  configLoader: CleanArchLinterConfigLoader(),
).addLintRule(DependencyDirectionRule.new).build();
