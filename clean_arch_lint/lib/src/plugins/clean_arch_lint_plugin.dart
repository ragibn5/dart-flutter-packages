import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_lint/src/rules/dependency_direction_rule/dependency_direction_rule.dart';

class CleanArchLintPlugin extends Plugin {
  final SessionDataManager _sessionDataManager;

  CleanArchLintPlugin(this._sessionDataManager);

  @override
  String get name => '$CleanArchLintPlugin';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(DependencyDirectionRule(_sessionDataManager));
  }
}
