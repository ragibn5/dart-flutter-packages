import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:analysis_server_plugin_core/src/models/context_config.dart';
import 'package:analysis_server_plugin_core/src/rules/session_managed_analysis_rule.dart';
import 'package:analysis_server_plugin_core/src/services/config/context_config_loader.dart';
import 'package:analysis_server_plugin_core/src/services/session/session_data_manager.dart';
import 'package:analysis_server_plugin_core/src/services/session/session_data_manager_factory.dart';

/// A factory function that creates a [SessionManagedAnalysisRule]
/// from a shared [SessionDataManager].
///
/// The generic type [C] links the rule to a specific [ContextConfig]
/// subclass, enforced at compile time by [PluginBuilder].
typedef SessionedRuleFactory<C extends ContextConfig> =
    SessionManagedAnalysisRule<C> Function(SessionDataManager);

/// A type-safe builder for constructing a [Plugin] backed by
/// [SessionManagedAnalysisRule]s.
///
/// The generic type [C] flows through every parameter, providing a
/// compile-time guarantee that the [ContextConfigLoader] and all registered
/// rules share the same config type.
///
/// Usage:
/// ```dart
/// final plugin = PluginBuilder<MyConfig>(
///     name: 'MyPlugin',
///     configLoader: MyConfigLoader(),
///     rules: [MyRule.new],
///   ).build();
/// ```
class PluginBuilder<C extends ContextConfig> {
  final String _pluginName;
  final ContextConfigLoader<C> _configLoader;
  final List<SessionedRuleFactory<C>> _ruleFactories;

  /// Creates a [PluginBuilder] for a plugin that uses config type [C].
  ///
  /// The [name] is a human-readable identifier reported to the Dart
  /// analysis server for error-reporting and insights-reporting.
  ///
  /// The [configLoader] produces the [ContextConfig] subclass of type [C]
  /// for each analyzed package. The generic type [C] flows from here
  /// through [rules], ensuring that all registered rules share the same
  /// config type at compile time.
  ///
  /// The [rules] is a list of rule factories. Each factory receives the
  /// shared [SessionDataManager] and must return a
  /// [SessionManagedAnalysisRule] parameterized with the same config
  /// type [C]. Pass an empty list if the plugin has no rules yet.
  PluginBuilder({
    required String name,
    required ContextConfigLoader<C> configLoader,
    required List<SessionedRuleFactory<C>> rules,
  }) : _pluginName = name,
       _configLoader = configLoader,
       _ruleFactories = rules;

  /// Builds a [Plugin] instance from the constructor parameters.
  ///
  /// Creates a single shared [SessionDataManager] and registers all
  /// rules added by this builder.
  Plugin build() {
    final sessionDataManager = SessionDataManagerFactory.createNewInstance(
      _configLoader,
    );

    return _BuiltPlugin<C>(
      pluginName: _pluginName,
      sessionDataManager: sessionDataManager,
      ruleFactories: List.unmodifiable(_ruleFactories),
    );
  }
}

class _BuiltPlugin<C extends ContextConfig> extends Plugin {
  final String _name;
  final SessionDataManager _sessionDataManager;
  final List<SessionedRuleFactory<C>> _ruleFactories;

  _BuiltPlugin({
    required String pluginName,
    required SessionDataManager sessionDataManager,
    required List<SessionedRuleFactory<C>> ruleFactories,
  }) : _name = pluginName,
       _sessionDataManager = sessionDataManager,
       _ruleFactories = ruleFactories;

  @override
  String get name => _name;

  @override
  void register(PluginRegistry registry) {
    for (final factory in _ruleFactories) {
      registry.registerLintRule(factory(_sessionDataManager));
    }
  }
}
