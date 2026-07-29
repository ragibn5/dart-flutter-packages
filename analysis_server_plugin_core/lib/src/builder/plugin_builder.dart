// ignore_for_file: avoid_returning_this

import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:analysis_server_plugin_core/src/models/context_config.dart';
import 'package:analysis_server_plugin_core/src/rules/session_managed_analysis_rule.dart';
import 'package:analysis_server_plugin_core/src/services/config/context_config_loader.dart';
import 'package:analysis_server_plugin_core/src/services/session/session_data_manager.dart';
import 'package:analysis_server_plugin_core/src/services/session/session_data_manager_factory.dart';

/// A factory function that creates a [SessionManagedAnalysisRule] from
/// a shared [SessionDataManager].
///
/// The generic type [C] links the rule to a specific [ContextConfig]
/// subclass, enforced at compile time by [PluginBuilder].
typedef SessionedRuleFactory<C extends ContextConfig> =
    SessionManagedAnalysisRule<C> Function(SessionDataManager);

/// A deferred registration callback that will be invoked with the
/// [PluginRegistry] and shared [SessionDataManager] when the plugin
/// is registered by the analysis server.
typedef _RuleRegistrationCallback =
    void Function(PluginRegistry, SessionDataManager);

/// A type-safe builder for constructing a [Plugin].
///
/// The generic type [C] flows through the config loader,
/// [addLintRule], and [addWarningRule], providing a compile-time
/// guarantee that the config loader and session-managed rules share
/// the same config type.
///
/// Usage:
/// ```dart
// ignore: lines_longer_than_80_chars
/// final plugin = PluginBuilder<MyConfig>(name: 'MyPlugin', configLoader: MyConfigLoader())
///   .addLintRule((sessionDataManager) => MyLintRule(sessionDataManager))
///   .addWarningRule((sessionDataManager) => MyWarningRule(sessionDataManager))
///   .build();
/// ```
class PluginBuilder<C extends ContextConfig> {
  final String _pluginName;
  final ContextConfigLoader<C> _configLoader;
  final List<_RuleRegistrationCallback> _registrations = [];

  /// Creates a [PluginBuilder] for a plugin that uses config type [C].
  ///
  /// - [name]: A human-readable identifier used by the Dart analysis server.
  /// - [configLoader]: Loads the config of type [C] for each analyzed package.
  PluginBuilder({
    required String name,
    required ContextConfigLoader<C> configLoader,
  }) : _pluginName = name,
       _configLoader = configLoader;

  /// Registers a lint rule factory.
  ///
  /// Each factory receives the shared [SessionDataManager] and must return a
  /// [SessionManagedAnalysisRule] parameterized with the same config type [C].
  PluginBuilder<C> addLintRule(SessionedRuleFactory<C> factory) {
    _registrations.add(
      (registry, sessionDataManager) =>
          registry.registerLintRule(factory(sessionDataManager)),
    );
    return this;
  }

  /// Registers a warning rule factory.
  ///
  /// Each factory receives the shared [SessionDataManager] and must
  /// return a [SessionManagedAnalysisRule] parameterized with the same
  /// config type [C].
  PluginBuilder<C> addWarningRule(SessionedRuleFactory<C> factory) {
    _registrations.add(
      (registry, sessionDataManager) =>
          registry.registerWarningRule(factory(sessionDataManager)),
    );
    return this;
  }

  /// Builds a [Plugin] instance from the registered components.
  ///
  /// Creates a single shared [SessionDataManager] and returns a plugin
  /// that registers everything via [PluginRegistry].
  Plugin build() {
    final sessionDataManager = SessionDataManagerFactory.createNewInstance(
      _configLoader,
    );

    return _BuiltPlugin<C>(
      pluginName: _pluginName,
      sessionDataManager: sessionDataManager,
      registrations: List.unmodifiable(_registrations),
    );
  }
}

class _BuiltPlugin<C extends ContextConfig> extends Plugin {
  final String _name;
  final SessionDataManager _sessionDataManager;
  final List<_RuleRegistrationCallback> _registrations;

  _BuiltPlugin({
    required String pluginName,
    required SessionDataManager sessionDataManager,
    required List<_RuleRegistrationCallback> registrations,
  }) : _name = pluginName,
       _sessionDataManager = sessionDataManager,
       _registrations = registrations;

  @override
  String get name => _name;

  @override
  void register(PluginRegistry registry) {
    for (final registration in _registrations) {
      registration(registry, _sessionDataManager);
    }
  }
}
