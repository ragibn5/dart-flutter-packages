import 'package:build/build.dart';
import 'package:generator_core/src/models/context_config.dart';
import 'package:meta/meta.dart';

abstract class ContextConfigLoader<C extends ContextConfig> {
  final BuilderOptions _builderOptions;

  ContextConfigLoader(this._builderOptions);

  /// Load plugin specific config.
  ///
  /// Note: The plugin specific custom options (and other builder options)
  /// can be found in [builderOptions].
  C loadPluginConfig(BuildStep buildStep, BuilderOptions builderOptions);

  /// Load the config for the given [BuildStep] instance.
  @mustCallSuper
  Future<ContextConfig> loadConfig(BuildStep buildStep) async {
    return loadPluginConfig(buildStep, _builderOptions);
  }
}
