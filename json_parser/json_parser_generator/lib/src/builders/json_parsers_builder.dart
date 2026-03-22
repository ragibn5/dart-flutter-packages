import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:json_parser_annotations/json_parser_annotations.dart';
import 'package:source_gen/source_gen.dart';

class JsonParsersBuilderConfig {
  /// Path relative to lib/, e.g. 'generated/json_parser/parsers.dart'.
  ///
  /// Note: This must match with one of the extension values under
  /// `builders.json_parsers_builder.build_extensions` found within build.yaml.
  final String outputPathRelativeToLib;

  const JsonParsersBuilderConfig({required this.outputPathRelativeToLib});

  String get outputPathRelativeToPackageRoot => 'lib/$outputPathRelativeToLib';
}

class JsonParsersBuilder implements Builder {
  final JsonParsersBuilderConfig _config;

  JsonParsersBuilder(this._config);

  @override
  Map<String, List<String>> get buildExtensions => {
    r'$lib$': [_config.outputPathRelativeToLib],
  };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    const annotation = TypeChecker.typeNamed(GenerateJsonParser);

    final annotatedClasses = await _getAnnotatedClasses(buildStep, annotation);
    if (annotatedClasses.isEmpty) {
      return;
    }

    final registryMap = _buildRegistryMap(annotatedClasses);
    final outputId = AssetId(
      buildStep.inputId.package,
      _config.outputPathRelativeToPackageRoot,
    );
    final emitter = DartEmitter(
      allocator: Allocator.simplePrefixing(),
      orderDirectives: true,
      useNullSafetySyntax: true,
    );
    final library = Library(
      (b) => b
        ..body.addAll(annotatedClasses.map((e) => _buildParserClass(e.$1)))
        ..body.addAll(
          registryMap.entries.map((e) => _buildRegistryClass(e.key, e.value)),
        ),
    );

    final output = DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    ).format(library.accept(emitter).toString());

    await buildStep.writeAsString(outputId, output);
  }

  Class _buildParserClass(ClassElement element) {
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

  Class _buildRegistryClass(String key, List<ClassElement> elements) {
    final className = '${_toPascalCase(key)}JsonParserRegistry';
    return Class(
      (b) => b
        ..name = className
        ..extend = refer(
          'JsonParserRegistry',
          'package:json_parser/src/registry/json_parser_registry.dart',
        )
        ..constructors.add(
          Constructor(
            (c) => c
              ..initializers.add(const Code('super.withKnownParsers()'))
              ..body = Block.of(
                elements.map(
                  (e) => refer('addParser').call([
                    refer('${e.displayName}JsonParser').newInstance([]),
                  ]).statement,
                ),
              ),
          ),
        ),
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

  Future<List<(ClassElement, Set<String>)>> _getAnnotatedClasses(
    BuildStep buildStep,
    TypeChecker annotation,
  ) async {
    final classes = <(ClassElement, Set<String>)>[];

    await for (final input in buildStep.findAssets(Glob('lib/**/*.dart'))) {
      if (!await buildStep.resolver.isLibrary(input)) {
        continue;
      }

      final library = await buildStep.resolver.libraryFor(input);
      final libraryReader = LibraryReader(library);

      for (final annotated in libraryReader.annotatedWith(annotation)) {
        if (annotated.element is! ClassElement) {
          continue;
        }

        final keysReader = annotated.annotation.read('registryKeys');
        final keys = keysReader.isNull
            ? <String>{}
            : keysReader.setValue
                  .map((e) => e.toStringValue()?.trim())
                  .where((key) => key?.isNotEmpty ?? false)
                  .whereType<String>()
                  .toSet();

        classes.add((annotated.element as ClassElement, keys));
      }
    }

    return classes;
  }

  Map<String, List<ClassElement>> _buildRegistryMap(
    List<(ClassElement, Set<String>)> annotatedClasses,
  ) {
    final registryMap = <String, List<ClassElement>>{};
    for (final (element, keys) in annotatedClasses) {
      for (final key in keys) {
        registryMap.putIfAbsent(key, () => []).add(element);
      }
    }
    return registryMap;
  }

  String _toPascalCase(String key) {
    if (key.isEmpty) return key;
    return key[0].toUpperCase() + key.substring(1);
  }
}
