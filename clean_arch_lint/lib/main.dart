import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:clean_arch_lint/src/rules/dependency_direction_rule/dependency_direction_rule.dart';
import 'package:clean_arch_lint/src/services/config/clean_arch_lint_config_loader.dart';

/// The plugin entry point.
///
/// The Dart Analysis Server looks for a top-level field named `plugin`.
/// So, DO NOT change the variable name. See this doc for more information:
/// https://dart.dev/tools/analyzer-plugins.
final plugin = CleanArchLintPlugin(
  SessionDataManager.createNewInstance(CleanArchLintConfigLoader()),
);

/// The main plugin class.
class CleanArchLintPlugin extends Plugin {
  final SessionDataManager _sessionDataManager;

  CleanArchLintPlugin(this._sessionDataManager);

  @override
  String get name => '$CleanArchLintPlugin';

  @override
  void register(PluginRegistry registry) {
    registry.registerWarningRule(DependencyDirectionRule(_sessionDataManager));
  }
}
