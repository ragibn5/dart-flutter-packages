import 'package:parser_generator/src/builders/json_parser/constants/json_config_constants.dart';
import 'package:string_extensions/string_extensions.dart';
import 'package:yaml/yaml.dart';

class JsonParserConfig {
  final JsonParserLocationConfig? defaultParserLocationConfig;
  final List<JsonParserLocationConfig> parserLocationConfigs;

  JsonParserConfig({
    required this.defaultParserLocationConfig,
    this.parserLocationConfigs = const [],
  });

  factory JsonParserConfig.fromYamlMap(YamlMap jsonParserConfig) {
    final defaultParserConfigMap = jsonParserConfig['default_parser'];
    final keyedParsersConfigMap = jsonParserConfig['keyed_parsers'];
    if (defaultParserConfigMap == null && keyedParsersConfigMap == null) {
      throw StateError(
        getJsonParserFormatError(
          header: 'Either `json_parser.default_parser` or '
              '`json_parser.keyed_parsers` must be specified.',
        ),
      );
    }
    if (defaultParserConfigMap is! YamlMap?) {
      throw StateError(getJsonParserFormatError());
    }
    if (keyedParsersConfigMap is! YamlList?) {
      throw StateError(getJsonParserFormatError());
    }

    final defaultParserConfig = defaultParserConfigMap != null
        ? JsonParserLocationConfig.fromYamlMap(null, defaultParserConfigMap)
        : null;

    final configs = <JsonParserLocationConfig>[];
    for (final item in (keyedParsersConfigMap ?? [])) {
      if (item is! YamlMap) {
        throw StateError(getJsonParserFormatError());
      }

      for (final entry in item.entries) {
        final parserKey = entry.key;
        final parserConfig = entry.value;
        if (parserKey is! String || parserConfig is! YamlMap) {
          throw StateError(getJsonParserFormatError());
        }

        configs
            .add(JsonParserLocationConfig.fromYamlMap(parserKey, parserConfig));
      }
    }

    return JsonParserConfig(
      parserLocationConfigs: configs,
      defaultParserLocationConfig: defaultParserConfig,
    );
  }
}

class JsonParserLocationConfig {
  final String? key;
  final String outputPath;
  final String outputClassName;

  const JsonParserLocationConfig({
    required this.key,
    required this.outputPath,
    required this.outputClassName,
  });

  factory JsonParserLocationConfig.fromYamlMap(
    String? key,
    YamlMap parserConfig,
  ) {
    try {
      final className =
          (parserConfig['class_name']?.toString()).nullOnEmptyOrBlank;
      final outputFile =
          (parserConfig['output_file']?.toString()).nullOnEmptyOrBlank;

      if (className == null || outputFile == null) {
        throw StateError(getJsonParserFormatError());
      }

      return JsonParserLocationConfig(
        key: key,
        outputPath: outputFile,
        outputClassName: className,
      );
    } catch (e) {
      if (e is StateError) rethrow;
      throw StateError(getJsonParserFormatError());
    }
  }
}
