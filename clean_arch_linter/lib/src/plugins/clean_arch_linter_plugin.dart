import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_linter/src/rules/dependency_direction_rule/dependency_direction_rule.dart';

class CleanArchLinterPlugin extends Plugin {
  final SessionDataManager _sessionDataManager;

  CleanArchLinterPlugin(this._sessionDataManager);

  @override
  String get name => '$CleanArchLinterPlugin';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(DependencyDirectionRule(_sessionDataManager));
  }
}
