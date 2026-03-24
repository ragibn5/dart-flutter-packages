import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:generator_core/generator_core.dart';
import 'package:json_parser_annotations/json_parser_annotations.dart';
import 'package:json_parser_generator/src/generators/parser_class_generator.dart';
import 'package:json_parser_generator/src/generators/registry_class_generator.dart';
import 'package:json_parser_generator/src/models/gjp_annotated_class.dart';
import 'package:json_parser_generator/src/readers/annotated_element_reader.dart';
import 'package:json_parser_generator/src/readers/gjp_annotation_reader.dart';

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
  final AnnotatedElementReader _annotatedElementReader;
  final GJPAnnotationReader _gjpAnnotationReader;
  final ParserClassGenerator _parserGenerator;
  final RegistryClassGenerator _registryGenerator;

  JsonParsersBuilder(
    this._config, {
    AnnotatedElementReader annotatedClassReader =
        const AnnotatedElementReader(),
    GJPAnnotationReader gjpAnnotationReader = const GJPAnnotationReader(),
    ParserClassGenerator parserClassGenerator = const ParserClassGenerator(),
    RegistryClassGenerator registryClassGenerator =
        const RegistryClassGenerator(),
  }) : _annotatedElementReader = annotatedClassReader,
       _gjpAnnotationReader = gjpAnnotationReader,
       _parserGenerator = parserClassGenerator,
       _registryGenerator = registryClassGenerator;

  @override
  Map<String, List<String>> get buildExtensions => {
    r'$lib$': [_config.outputPathRelativeToLib],
  };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    const annotation = TypeChecker.typeNamed(GenerateJsonParser);
    final annotatedElements = await _annotatedElementReader.read(
      buildStep,
      annotation,
      excludePathPrefix: 'lib/generated/',
    );

    final annotatedClasses = _gjpAnnotationReader.read(annotatedElements);
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
        ..body.addAll(
          annotatedClasses.map((e) => _parserGenerator.generate(e.element)),
        )
        ..body.addAll(
          registryMap.entries.map(
            (e) => _registryGenerator.generateRegistryClass(e.key, e.value),
          ),
        ),
    );

    final output = DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    ).format(library.accept(emitter).toString());
    await buildStep.writeAsString(outputId, output);
  }

  Map<String, List<ClassElement>> _buildRegistryMap(
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
}
