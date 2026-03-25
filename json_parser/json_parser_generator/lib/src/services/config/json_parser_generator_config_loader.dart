import 'package:generator_core/generator_core.dart';
import 'package:json_parser_generator/src/models/json_parser_generator_context_config.dart';

class JsonParserGeneratorConfigLoader
    extends ContextConfigLoader<JsonParserGeneratorContextConfig> {
  JsonParserGeneratorConfigLoader(super.builderOptions);

  @override
  JsonParserGeneratorContextConfig loadPluginConfig(
    BuildStep buildStep,
    BuilderOptions builderOptions,
    PackageInfo packageInfo,
  ) {
    // TODO: implement loadPluginConfig
    throw UnimplementedError();
  }
}
