import 'package:build/build.dart';
import 'package:parser_generator/src/builders/json_parser/collectors/legacy_json_model_collector.dart';
import 'package:parser_generator/src/builders/json_parser/constants/json_config_constants.dart';
import 'package:parser_generator/src/builders/json_parser/models/configs/parser_config.dart';
import 'package:parser_generator/src/builders/json_parser/models/json_parser_builder_metadata.dart';
import 'package:parser_generator/src/builders/json_parser/services/json_parser_generator.dart';
import 'package:parser_generator/src/builders/json_parser/services/parser_config_reader.dart';
import 'package:source_gen/source_gen.dart';

Builder jsonParserBuilder(BuilderOptions options) {
  Future<void> handleGeneration(JsonParserBuilderMetadata data) async {
    if (data.data.isEmpty) {
      log.info(
        '`$jsonParserBuilderId` received empty list, '
        'exiting without any code generation.',
      );
      return;
    }

    ParserConfig parserConfig;
    try {
      parserConfig = await ParserConfigReader().readConfig(options);
    } catch (e, st) {
      log.severe('Error while obtaining `ParserConfig`.', e, st);
      return;
    }

    final jsonParserConfig = parserConfig.jsonParserConfig;
    if (jsonParserConfig == null) {
      log.severe(
        getJsonParserFormatError(
          header: 'Requested json parser generation, but no '
              '`json_parser` config was found within `parser_config.yaml`',
        ),
      );
      return;
    }

    await JsonParserGenerator().generate(jsonParserConfig, data);
  }

  return SharedPartBuilder(
    [
      LegacyJsonModelCollector(
        Resource<JsonParserBuilderMetadata>(
          () => JsonParserBuilderMetadata([], options),
          dispose: handleGeneration,
        ),
      ),
    ],
    jsonParserBuilderId,
  );
}
