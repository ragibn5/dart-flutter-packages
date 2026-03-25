import 'package:generator_core/generator_core.dart';
import 'package:json_parser_generator/src/builders/json_parsers_builder.dart';
import 'package:json_parser_generator/src/services/config/json_parser_generator_config_loader.dart';

Builder jsonParsersBuilder(BuilderOptions options) => JsonParsersBuilder(
  const JsonParsersBuilderConfig(
    outputPathRelativeToLib: 'generated/json_parser/parsers.dart',
  ),
  sessionDataManager: SessionDataManager.createNewInstance(
    JsonParserGeneratorConfigLoader(options),
  ),
);
