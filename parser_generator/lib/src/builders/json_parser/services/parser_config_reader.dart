import 'dart:io';

import 'package:build/build.dart';
import 'package:generator_core/generator_core.dart';
import 'package:parser_generator/src/builders/json_parser/models/configs/parser_config.dart';
import 'package:string_extensions/string_extensions.dart';
import 'package:yaml/yaml.dart';

class ParserConfigReader implements ConfigReader<ParserConfig> {
  @override
  Future<ParserConfig> readConfig(BuilderOptions options) async {
    final configFilePath =
        (options.config['config_file'] as String?).nullOnEmptyOrBlank;
    if (configFilePath == null) {
      throw StateError(
        'Internal error: Could not find `config_file` key in build file.',
      );
    }

    final configFile = File(configFilePath);
    if (!configFile.existsSync()) {
      throw StateError(
        "Couldn't find config file in host project. "
        'Typically this file is/should be located at <host-project-root>/parser_config.yaml',
      );
    }

    final configContent = (await configFile.readAsString()).nullOnEmptyOrBlank;
    if (configContent == null) {
      throw StateError('Empty/Blank config file.');
    }

    final configYaml = loadYaml(configContent);
    if (configYaml is! YamlMap) {
      throw StateError(
        'Invalid config data - expected YAML map at root level.',
      );
    }

    return ParserConfig.fromYamlMap(configYaml);
  }
}
