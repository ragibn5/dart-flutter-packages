import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';

class ParserClassGenerator {
  const ParserClassGenerator();

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
        ..name = '${element.displayName}JsonParser'
        ..implements.add(
          TypeReference(
            (b) => b
              ..symbol = 'Parser'
              ..url = 'package:json_parser/json_parser.dart'
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
            ..name = 'value'
            ..type = elementType,
        ),
      )
      ..body = const Code('value.toJson()'),
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
            ..name = 'encoded'
            ..type = mapType,
        ),
      )
      ..body = refer(
        elementType.symbol!,
        sourceUri,
      ).property('fromJson').call([refer('encoded')]).code,
  );
}
