import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:json_parser_generator/src/generators/registry_class_generator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockClassElement extends Mock implements ClassElement {}

void main() {
  const config = RegistryClassGeneratorConfig(
    classSuffix: 'JsonParserRegistry',
    parserSuffix: 'JsonParser',
    registryUri: 'package:json_parser/src/registry/json_parser_registry.dart',
  );

  late DartEmitter emitter;
  late RegistryClassGenerator generator;

  setUp(() {
    emitter = DartEmitter(useNullSafetySyntax: true);
    generator = const RegistryClassGenerator.test(config);
  });

  _MockClassElement mockElement(String name) {
    final element = _MockClassElement();
    when(() => element.displayName).thenReturn(name);
    return element;
  }

  String generate(String key, List<ClassElement> elements) =>
      generator.generateRegistryClass(key, elements).accept(emitter).toString();

  String buildExpectedPattern(String key, List<String> elementNames) {
    final pascalKey = key[0].toUpperCase() + key.substring(1);
    final parsers = elementNames
        .map((n) => '\\s*addParser\\($n${config.parserSuffix}\\(\\)\\);')
        .join();

    return 'class\\s*$pascalKey${config.classSuffix}\\s*extends\\s*JsonParserRegistry\\s*\\{'
        '\\s*$pascalKey${config.classSuffix}\\(\\)\\s*:\\s*super\\.withKnownParsers\\(\\)\\s*\\{'
        '$parsers'
        r'\s*\}'
        r'\s*\}';
  }

  void expectCorrectRegistryClass(String key, List<String> elementNames) {
    final elements = elementNames.map(mockElement).toList();
    expect(
      generate(key, elements),
      matches(buildExpectedPattern(key, elementNames)),
    );
  }

  test('Generates correct registry class', () {
    expectCorrectRegistryClass('key1', ['User', 'Product', 'Order']);
    expectCorrectRegistryClass('key2', [
      'User',
      'Product',
      'Order',
      'Cart',
      'Item',
      'Address',
    ]);
  });
}
