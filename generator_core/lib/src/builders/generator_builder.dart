import 'package:generator_core/src/models/context_config.dart';
import 'package:generator_core/src/services/config/context_config_loader.dart';
import 'package:generator_core/src/services/session/session_data_manager.dart';

/// A type-safe builder that wires a [ContextConfigLoader] and a single
/// builder/generator factory to a shared [SessionDataManager].
///
/// The generic type [C] is the config type. The generic type [B] is
/// the concrete builder/generator type produced by [build].
///
/// Usage:
/// ```dart
/// Builder jsonParsersBuilder(BuilderOptions options) {
///   return GeneratorBuilder<JsonParserConfig, JsonParsersBuilder>(
///     configLoader: JsonParserGeneratorConfigLoader(options),
///     factory: (sessionDataManager) => JsonParsersBuilder(sessionDataManager),
///   ).build();
/// }
/// ```
class GeneratorBuilder<C extends ContextConfig, B> {
  final ContextConfigLoader<C> _configLoader;
  final B Function(SessionDataManager) _factory;

  GeneratorBuilder({
    required ContextConfigLoader<C> configLoader,
    required B Function(SessionDataManager) factory,
  }) : _configLoader = configLoader,
       _factory = factory;

  /// Creates a [SessionDataManager] from the config loader and
  /// invokes the factory to produce the final builder/generator.
  B build() {
    return _factory(SessionDataManager.createNewInstance(_configLoader));
  }
}
