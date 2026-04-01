import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:json_parser_generator/src/generators/parser_class_generator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockClassElement extends Mock implements ClassElement {}

class _MockLibraryElement extends Mock implements LibraryElement {}

void main() {
  const config = ParserClassGeneratorConfig(
    classSuffix: 'JsonParser',
    jsonParserUri: 'package:json_parser/json_parser.dart',
    encodeParamName: 'value',
    decodeParamName: 'encoded',
  );

  late DartEmitter emitter;

  late _MockClassElement mockClassElement;
  late _MockLibraryElement mockLibraryElement;

  late ParserClassGenerator generator;

  setUp(() {
    emitter = DartEmitter(useNullSafetySyntax: true);

    mockClassElement = _MockClassElement();
    mockLibraryElement = _MockLibraryElement();

    generator = const ParserClassGenerator.test(config);

    when(() => mockClassElement.displayName).thenReturn('User');
    when(() => mockClassElement.library).thenReturn(mockLibraryElement);
    when(
      () => mockLibraryElement.uri,
    ).thenReturn(Uri.parse('package:example/user.dart'));
  });

  String generate() =>
      generator.generate(mockClassElement).accept(emitter).toString();

  test('Generates correct parser class', () {
    expect(
      generate(),
      matches(
        'class\\s*User${config.classSuffix}\\s*implements\\s*Parser<User,\\s*Map<String,\\s*dynamic>>\\s*\\{'
        '\\s*@override\\s*Map<String,\\s*dynamic>\\s*encode\\s*\\(\\s*User\\s*${config.encodeParamName}\\s*\\)\\s*=>\\s*${config.encodeParamName}\\.toJson\\(\\);'
        '\\s*@override\\s*User\\s*decode\\s*\\(\\s*Map<String,\\s*dynamic>\\s*${config.decodeParamName}\\s*\\)\\s*=>\\s*User\\.fromJson\\(${config.decodeParamName}\\);'
        r'\s*\}',
      ),
    );
  });
}
