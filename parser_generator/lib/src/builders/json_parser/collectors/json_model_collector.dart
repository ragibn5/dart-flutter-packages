import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/type_provider.dart';
import 'package:analyzer_core/analyzer_core.dart';
import 'package:build/build.dart';
import 'package:parser_annotations/parser_annotations.dart';
import 'package:parser_generator/src/builders/json_parser/models/json_coder_metadata.dart';
import 'package:parser_generator/src/builders/json_parser/models/json_parser_builder_metadata.dart';
import 'package:source_gen/source_gen.dart';

class JsonModelCollector extends GeneratorForAnnotation<JsonCodable> {
  final Resource<JsonParserBuilderMetadata> _sharedResource;

  JsonModelCollector(this._sharedResource);

  @override
  Future<void> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final debugName = element.displayName;
    if (element is! ClassElement2) {
      log.info(
        'Found `@$JsonCodable` with a non-class entity (`$debugName`), '
        'ignoring...',
      );
      return;
    }

    final autoRegister = annotation.read('autoRegister').boolValue;
    if (!autoRegister) {
      return;
    }

    final classElement = element as ClassElement2;
    final typeProvider = (await buildStep.inputLibrary).typeProvider;

    final requireFromJson = annotation.read('requireFromJson').boolValue;
    final fromJson = _findFromJsonConstructorMatch(classElement, typeProvider);
    if (requireFromJson && fromJson == null) {
      log.severe(
        "`$debugName` doesn't have a `fromJson` factory constructor, "
        'exiting...',
      );
      return;
    }

    final parserKeys = annotation.read('parserKeys');
    if (requireFromJson && fromJson == null) {
      log.severe(
        "`$debugName` doesn't have a `fromJson` factory constructor, "
        'exiting...',
      );
      return;
    }

    await _addToSharedStorage(
      classElement,
      buildStep,
      parserKeys.setValue
          .map((e) => e.toStringValue())
          .where((e) => e != null)
          .map((e) => e!)
          .toSet(),
    );
  }

  Future<void> _addToSharedStorage(
    ClassElement2 classElement,
    BuildStep buildStep,
    Set<String> parserKeys,
  ) async {
    final sharedData = await buildStep.fetchResource(_sharedResource);
    sharedData.data.add(
      JsonCoderMetadata(
        classElement.library2.uri,
        classElement.displayName,
        parserKeys,
      ),
    );
  }

  ConstructorElement2? _findFromJsonConstructorMatch(
    ClassElement2 classElement,
    TypeProvider typeProvider,
  ) {
    const name = 'fromJson';

    final method = classElement.getNamedConstructor2(name);
    if (method == null) {
      return null;
    }

    final expectedSignature = ConstructorSignature(
      isConst: false,
      isStatic: false,
      isPublic: true,
      isPrivate: false,
      isFactory: true,
      isExternal: false,
      isSynthetic: false,
      name: name,
      parameters: [
        ParameterSignature(
          type: typeProvider.mapType(
            typeProvider.stringType,
            typeProvider.dynamicType,
          ),
          name: 'json',
          isNamed: false,
          isRequired: true,
        ),
      ],
    );

    final validator = ConstructorValidator();
    final validationError = validator.validate(
      actual: ConstructorSignature.fromConstructorElement2(method),
      expected: expectedSignature,
    );

    return validationError != null ? method : null;
  }
}
