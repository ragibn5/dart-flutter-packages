// ignore_for_file: unnecessary_lambdas

import 'package:analysis_plugin_test_helper/analysis_plugin_test_helper.dart';
import 'package:analysis_server_plugin_core/src/services/resolvers/type_resolvers/annotation_type_resolver.dart';
import 'package:test/test.dart';

void main() {
  final dartResolver = DartUnitResolver();

  late ConstantValueAnnotationTypeResolver sut;

  setUpAll(() async {
    await dartResolver.setUp();
  });

  setUp(() {
    sut = const ConstantValueAnnotationTypeResolver();
  });

  tearDownAll(() async {
    await dartResolver.tearDown();
  });

  test(
    'Returns class name for direct annotation form @GenerateJsonParser()',
    () async {
      final resolved = await dartResolver.resolveSource('''
      class GenerateJsonParser {
        const GenerateJsonParser();
      }

      @GenerateJsonParser()
      class Foo {}
      ''');
      final annotation = getAnnotation(
        resolved.unit,
        annotationName: 'GenerateJsonParser',
      );

      final result = sut.resolveTypeName(annotation);

      expect(result, 'GenerateJsonParser');
    },
  );

  test('Returns class name for const variable form @ann', () async {
    final resolved = await dartResolver.resolveSource('''
    class GenerateJsonParser {
      const GenerateJsonParser();
    }

    const ann = GenerateJsonParser();

    @ann
    class Foo {}
    ''');
    final annotation = getAnnotation(
      resolved.unit,
      annotationName: 'GenerateJsonParser',
    );
    expect(annotation, isNotNull);

    final result = sut.resolveTypeName(annotation);

    expect(result, 'GenerateJsonParser');
  });

  test('Returns class name for typedef alias form', () async {
    final resolved = await dartResolver.resolveSource('''
    class GenerateJsonParser {
      const GenerateJsonParser();
    }

    typedef GJP = GenerateJsonParser;

    @GJP()
    class Foo {}
    ''');
    final annotation = getAnnotation(
      resolved.unit,
      annotationName: 'GenerateJsonParser',
    );
    expect(annotation, isNotNull);

    final result = sut.resolveTypeName(annotation);

    expect(result, 'GenerateJsonParser');
  });
}
