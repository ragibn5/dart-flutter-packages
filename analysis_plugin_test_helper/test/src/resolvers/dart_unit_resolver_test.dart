import 'package:analysis_plugin_test_helper/analysis_plugin_test_helper.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:test/test.dart';

void main() {
  final resolver = DartUnitResolver();

  setUpAll(() async {
    await resolver.setUp();
  });

  tearDownAll(() async {
    await resolver.tearDown();
  });

  test(
    'resolveSource returns ResolvedUnitResult for valid Dart code',
    () async {
      final source = '''
      void main() {
        print('Hello, World!');
      }
      ''';

      final result = await resolver.resolveSource(source);

      expect(result, isA<ResolvedUnitResult>());
      expect(result.unit, isNotNull);
      expect(result.unit.declarations, isNotEmpty);
    },
  );

  test('resolveSource handles empty source', () async {
    final source = '';

    final result = await resolver.resolveSource(source);

    expect(result, isA<ResolvedUnitResult>());
    expect(result.unit.declarations, isEmpty);
  });

  test('resolveSource handles invalid Dart code', () async {
    final invalidSource = '''
    void main() {
      print('Hello, World!' // Missing closing parenthesis
    }
    ''';

    final result = await resolver.resolveSource(invalidSource);

    expect(result, isA<ResolvedUnitResult>());
    expect(result.diagnostics, isNotEmpty);
  });

  test(
    'resolveSource resolves imports, annotations, classes, constructors, methods, etc.',
    () async {
      final source = '''
      import 'dart:core';
      
      class MyAnnotation {
        const MyAnnotation();
      }
  
      @MyAnnotation()
      class Foo {
        Foo();
        
        Foo.named();
        
        factory Foo.named();
      
        void myMethod() {}
        
        static myStaticMethod() {}
      }
      ''';

      final result = await resolver.resolveSource(source);

      expect(result.unit.declarations.length, equals(2));

      // Import related check
      final imports = result.unit.directives.whereType<ImportDirective>();
      expect(imports.length, equals(1));

      // Class related checks
      final fooClass = result.unit.declarations[1] as ClassDeclaration;
      // Class existence check
      expect(fooClass.name.lexeme, equals('Foo'));
      // Annotation existence check
      expect(fooClass.metadata, isNotEmpty);
      // Constructor existence check
      expect(
        fooClass.members.whereType<ConstructorDeclaration>(),
        hasLength(3),
      );
      // Method existence check
      expect(fooClass.members.whereType<MethodDeclaration>(), hasLength(2));
    },
  );
}
