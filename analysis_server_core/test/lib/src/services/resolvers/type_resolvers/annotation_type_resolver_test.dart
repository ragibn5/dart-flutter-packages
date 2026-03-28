// ignore_for_file: unnecessary_lambdas

import 'package:analysis_plugin_test_helper/analysis_plugin_test_helper.dart';
import 'package:analysis_server_core/src/services/resolvers/type_resolvers/annotation_type_resolver.dart';
import 'package:test/test.dart';

void main() {
  final unitResolver = DartUnitResolver();

  late ConstantValueAnnotationTypeResolver annotationResolver;

  setUp(() {
    unitResolver.setUp();
    annotationResolver = const ConstantValueAnnotationTypeResolver();
  });

  tearDown(() {
    unitResolver.tearDown();
  });

  test(
    'Returns class name for direct annotation form @GenerateJsonParser()',
    () async {
      final resolved = await unitResolver.resolveSource('''
      class GenerateJsonParser {
        const GenerateJsonParser();
      }

      @GenerateJsonParser()
      class Foo {}
      ''');
      final annotation = resolved.findAnnotation(
        annotationName: 'GenerateJsonParser',
      );
      expect(annotation, isNotNull);

      final result = annotationResolver.resolveTypeName(annotation!);

      expect(result, 'GenerateJsonParser');
    },
  );

  test('Returns class name for const variable form @ann', () async {
    final resolved = await unitResolver.resolveSource('''
    class GenerateJsonParser {
      const GenerateJsonParser();
    }

    const ann = GenerateJsonParser();

    @ann
    class Foo {}
    ''');
    final annotation = resolved.findAnnotation(annotationName: 'ann');
    expect(annotation, isNotNull);

    final result = annotationResolver.resolveTypeName(annotation!);

    expect(result, 'GenerateJsonParser');
  });

  test('Returns class name for typedef alias form', () async {
    final resolved = await unitResolver.resolveSource('''
    class GenerateJsonParser {
      const GenerateJsonParser();
    }

    typedef GJP = GenerateJsonParser;

    const ann = GJP();

    @ann
    class Foo {}
    ''');
    final annotation = resolved.findAnnotation(annotationName: 'ann');
    expect(annotation, isNotNull);

    final result = annotationResolver.resolveTypeName(annotation!);

    expect(result, 'GenerateJsonParser');
  });
}
