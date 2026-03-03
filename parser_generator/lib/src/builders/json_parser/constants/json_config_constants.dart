const jsonParserBuilderId = 'json_parser_builder';
const jsonParserKey = 'json_parser';
const defaultJsonParserKey = 'default_parser';
const keyedJsonParsersKey = 'keyed_parsers';
const jsonParserClassNameKey = 'class_name';
const jsonParserOutputPathKey = 'output_file';

String getJsonParserFormatError({String? header}) {
  return '''
${header ?? 'Invalid parser configuration.'}

Expected:
__________

$jsonParserKey:
  # Default config
  $defaultJsonParserKey:
    $jsonParserClassNameKey: DefaultModelsParser
    $jsonParserOutputPathKey: /path/to/default_models_parser.dart
  # Specific configs
  $keyedJsonParsersKey:
    # Individual parser configs go here.
    - network_models_parser:
        $jsonParserClassNameKey: NetworkModelsParser
        $jsonParserOutputPathKey: /path/to/network_models_parser.dart
    - ipc_models_parser:
        $jsonParserClassNameKey: IpcModelsParser
        $jsonParserOutputPathKey: /path/to/ipc_models_parser.dart

__________

''';
}
