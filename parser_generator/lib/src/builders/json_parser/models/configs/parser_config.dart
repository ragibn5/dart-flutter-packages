import 'package:parser_generator/src/builders/json_parser/constants/json_config_constants.dart';
import 'package:parser_generator/src/builders/json_parser/models/configs/json_parser_config.dart';
import 'package:yaml/yaml.dart';

class ParserConfig {
  final JsonParserConfig? jsonParserConfig;

  ParserConfig({this.jsonParserConfig});

  factory ParserConfig.fromYamlMap(YamlMap configYaml) {
    final jsonParserConfig = configYaml[jsonParserKey];
    if (jsonParserConfig is! YamlMap?) {
      throw StateError(getJsonParserFormatError());
    }

    return ParserConfig(
      jsonParserConfig: jsonParserConfig == null
          ? null
          : JsonParserConfig.fromYamlMap(jsonParserConfig),
    );
  }
}
