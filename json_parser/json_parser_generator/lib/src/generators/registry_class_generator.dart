import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:json_parser_generator/src/models/gjp_annotated_class.dart';
import 'package:meta/meta.dart';

class RegistryClassGeneratorConfig {
  final String classSuffix;
  final String parserSuffix;
  final String registryUri;

  const RegistryClassGeneratorConfig({
    required this.classSuffix,
    required this.parserSuffix,
    required this.registryUri,
  });
}

class RegistryClassGenerator {
  final RegistryClassGeneratorConfig _config;

  const RegistryClassGenerator()
    : this._(
        const RegistryClassGeneratorConfig(
          classSuffix: 'JsonParserRegistry',
          parserSuffix: 'JsonParser',
          registryUri:
              'package:json_parser/src/registry/json_parser_registry.dart',
        ),
      );

  @visibleForTesting
  const RegistryClassGenerator.test(RegistryClassGeneratorConfig config)
    : this._(config);

  const RegistryClassGenerator._(this._config);

  Map<String, List<ClassElement>> buildRegistryMap(
    List<GJPAnnotatedClass> annotatedClasses,
  ) {
    final registryMap = <String, List<ClassElement>>{};
    for (final item in annotatedClasses) {
      for (final key in item.config.registryKeys) {
        final list = registryMap.putIfAbsent(key, () => []);
        if (!list.contains(item.element)) {
          list.add(item.element);
        }
      }
    }
    return registryMap;
  }

  Class generateRegistryClass(String key, List<ClassElement> elements) {
    final className = '${_toPascalCase(key)}${_config.classSuffix}';
    return Class(
      (b) => b
        ..name = className
        ..extend = refer('JsonParserRegistry', _config.registryUri)
        ..constructors.add(
          Constructor(
            (c) => c
              ..initializers.add(const Code('super.withKnownParsers()'))
              ..body = Block.of(
                elements.map(
                  (e) => refer('addParser').call([
                    refer(
                      '${e.displayName}${_config.parserSuffix}',
                    ).newInstance([]),
                  ]).statement,
                ),
              ),
          ),
        ),
    );
  }

  String _toPascalCase(String key) {
    if (key.isEmpty) {
      return key;
    }
    return key[0].toUpperCase() + key.substring(1);
  }
}
