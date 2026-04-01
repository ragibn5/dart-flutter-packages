import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:meta/meta.dart';

class ParserClassGeneratorConfig {
  final String classSuffix;
  final String jsonParserUri;
  final String encodeParamName;
  final String decodeParamName;

  const ParserClassGeneratorConfig({
    required this.classSuffix,
    required this.jsonParserUri,
    required this.encodeParamName,
    required this.decodeParamName,
  });
}

class ParserClassGenerator {
  final ParserClassGeneratorConfig _config;

  const ParserClassGenerator()
    : this._(
        const ParserClassGeneratorConfig(
          classSuffix: 'JsonParser',
          jsonParserUri: 'package:json_parser/json_parser.dart',
          encodeParamName: 'value',
          decodeParamName: 'encoded',
        ),
      );

  @visibleForTesting
  const ParserClassGenerator.test(ParserClassGeneratorConfig config)
    : this._(config);

  const ParserClassGenerator._(this._config);

  Class generate(ClassElement element) {
    final sourceUri = element.library.uri.toString();
    final elementType = refer(element.displayName, sourceUri);
    final mapType = TypeReference(
      (b) => b
        ..symbol = 'Map'
        ..types.addAll([refer('String'), refer('dynamic')]),
    );

    return Class(
      (b) => b
        ..name = '${element.displayName}${_config.classSuffix}'
        ..implements.add(
          TypeReference(
            (b) => b
              ..symbol = 'Parser'
              ..url = _config.jsonParserUri
              ..types.addAll([elementType, mapType]),
          ),
        )
        ..methods.addAll([
          _encodeMethod(elementType, mapType),
          _decodeMethod(elementType, mapType, sourceUri),
        ]),
    );
  }

  Method _encodeMethod(Reference elementType, TypeReference mapType) => Method(
    (m) => m
      ..name = 'encode'
      ..returns = mapType
      ..annotations.add(refer('override'))
      ..lambda = true
      ..requiredParameters.add(
        Parameter(
          (p) => p
            ..name = _config.encodeParamName
            ..type = elementType,
        ),
      )
      ..body = Code('${_config.encodeParamName}.toJson()'),
  );

  Method _decodeMethod(
    Reference elementType,
    TypeReference mapType,
    String sourceUri,
  ) => Method(
    (m) => m
      ..name = 'decode'
      ..returns = elementType
      ..annotations.add(refer('override'))
      ..lambda = true
      ..requiredParameters.add(
        Parameter(
          (p) => p
            ..name = _config.decodeParamName
            ..type = mapType,
        ),
      )
      ..body = refer(
        elementType.symbol!,
        sourceUri,
      ).property('fromJson').call([refer(_config.decodeParamName)]).code,
  );
}
