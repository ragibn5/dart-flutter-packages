// Example usage of the analysis_plugin_test_helper package.
// For a complete demonstration, see the test codes in the `test` folder.

import 'package:analysis_plugin_test_helper/analysis_plugin_test_helper.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:test/test.dart';

void main() {
  final resolver = DartUnitResolver();

  setUpAll(() async => resolver.setUp());
  tearDownAll(() async => resolver.tearDown());

  test('resolve Dart source string', () async {
    final result = await resolver.resolveSource('''
      class MyAnnotation {
        const MyAnnotation();
      }

      @MyAnnotation()
      class Foo {
        void myMethod() {}
      }
    ''');

    expect(result.diagnostics, isEmpty);
    // result.unit is a fully resolved CompilationUnit
  });

  test('find annotation on class', () async {
    final result = await resolver.resolveSource('''
      class MyAnnotation {
        const MyAnnotation();
      }

      @MyAnnotation()
      class Foo {}
    ''');

    final annotation = findAnnotation<ClassDeclaration>(
      result.unit,
      annotationName: 'MyAnnotation',
    );
    expect(annotation, isNotNull);
  });

  test('find method by name', () async {
    final result = await resolver.resolveSource('''
      class MyClass {
        void myMethod() {}
      }
    ''');

    final method = findMethodDeclaration(result.unit, 'myMethod');
    expect(method, isNotNull);
  });

  test('find constructor by name', () async {
    final result = await resolver.resolveSource('''
      class MyClass {
        MyClass();
        MyClass.named();
      }
    ''');

    final defaultCtor = findConstructorDeclaration(result.unit, null);
    final namedCtor = findConstructorDeclaration(result.unit, 'named');

    expect(defaultCtor, isNotNull);
    expect(namedCtor, isNotNull);
  });

  test('find import directive', () async {
    final result = await resolver.resolveSource('''
      import 'dart:core';

      class MyClass {}
    ''');

    final importDirective = findImportDirective(result.unit);
    expect(importDirective, isNotNull);
  });
}
