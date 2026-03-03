import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';
import 'package:generator_core/generator_core.dart';
import 'package:parser/parser.dart';
import 'package:parser_generator/src/builders/json_parser/models/configs/json_parser_config.dart';
import 'package:parser_generator/src/builders/json_parser/models/json_coder_metadata.dart';
import 'package:parser_generator/src/builders/json_parser/models/json_parser_builder_metadata.dart';

class JsonParserGenerator
    implements PostBuildGenerator<JsonParserConfig, JsonParserBuilderMetadata> {
  @override
  Future<void> generate(
    JsonParserConfig config,
    JsonParserBuilderMetadata inputData,
  ) async {
    final codersByKey = _organizeCodersByKey(inputData.data);
    await _processDefaultCoders(config, codersByKey.defaultCoders);
    await _processKeyedCoders(config, codersByKey.keyedCoders);
  }

  _CodersByKey _organizeCodersByKey(List<JsonCoderMetadata> coders) {
    final defaultCoders = <JsonCoderMetadata>[];
    final keyedCoders = <String, List<JsonCoderMetadata>>{};

    for (final coder in coders) {
      final keys = coder.parserKeys;
      if (keys.isEmpty) {
        defaultCoders.add(coder);
      } else {
        for (final key in keys) {
          keyedCoders.putIfAbsent(key, () => []).add(coder);
        }
      }
    }

    return _CodersByKey(defaultCoders, keyedCoders);
  }

  Future<void> _processDefaultCoders(
    JsonParserConfig config,
    List<JsonCoderMetadata> defaultCoders,
  ) async {
    if (defaultCoders.isEmpty) return;

    final locationConfig = config.defaultParserLocationConfig;
    if (locationConfig == null) {
      log.severe(
        'Found entries without specific parser key, but '
        'default parser config was not found inside `parser_config.yaml`',
      );
      return;
    }

    await _writeToTarget(locationConfig, defaultCoders);
  }

  Future<void> _processKeyedCoders(
    JsonParserConfig config,
    Map<String, List<JsonCoderMetadata>> keyedCoders,
  ) async {
    for (final entry in keyedCoders.entries) {
      final key = entry.key;
      final coders = entry.value;
      if (coders.isEmpty) continue;

      final locationConfig =
          config.parserLocationConfigs.where((e) => e.key == key).firstOrNull;
      if (locationConfig == null) {
        log.severe(
          // ignore: lines_longer_than_80_chars
          'Found entries with parser key `$key`, but no matching parser config was found. '
          // ignore: lines_longer_than_80_chars
          'Ensure matching keys exist in both annotations and parser_config.yaml.',
        );
        return;
      }

      await _writeToTarget(locationConfig, coders);
    }
  }

  Future<void> _writeToTarget(
    JsonParserLocationConfig config,
    List<JsonCoderMetadata> data,
  ) async {
    final file = File(config.outputPath);
    if (!file.existsSync()) {
      await file.create(recursive: true);
    }

    await file.writeAsString(
      flush: true,
      _buildSourceContent(config, data),
    );
  }

  String _buildSourceContent(
    JsonParserLocationConfig config,
    List<JsonCoderMetadata> data,
  ) {
    final lineSeparator = Platform.lineTerminator;
    final importSet = data
        .map((e) => "import '${e.uri}' as i${_getLibraryId(e.uri)};")
        .toSet();
    final decoderSet = data
        .map((e) => 'addDecoder(i${_getLibraryId(e.uri)}.${e.name}.fromJson);')
        .toSet();

    return '''
// GENERATED CODE
// THE CODE MAY NOT BE FORMATTED, PLEASE FORMAT PROPERLY

import 'package:parser/parser.dart';
${importSet.join(lineSeparator)}

class ${config.outputClassName} extends $JsonParser {
  ${config.outputClassName}() {
    ${decoderSet.join(lineSeparator)}
  }
}
''';
  }

  String _getLibraryId(Uri uri) {
    final libraryId = uri.toString().hashCode;
    return '$libraryId'.replaceAll('-', '_');
  }
}

class _CodersByKey {
  final List<JsonCoderMetadata> defaultCoders;
  final Map<String, List<JsonCoderMetadata>> keyedCoders;

  _CodersByKey(this.defaultCoders, this.keyedCoders);
}
