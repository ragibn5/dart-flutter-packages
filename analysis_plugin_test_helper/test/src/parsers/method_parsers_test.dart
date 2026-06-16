import 'package:analysis_plugin_test_helper/analysis_plugin_test_helper.dart';
import 'package:test/test.dart';

void main() {
  final resolver = DartUnitResolver();

  setUpAll(() async {
    await resolver.setUp();
  });

  tearDownAll(() async {
    await resolver.tearDown();
  });

  test('findMethodDeclaration returns method declaration', () async {
    final resolved = await resolver.resolveSource('''
    class MyClass {
      void myMethod() {}
    }
    ''');

    final method = findMethodDeclaration(resolved.unit, 'myMethod');

    expect(method, isNotNull);
  });

  test('findMethodDeclaration returns null if not found', () async {
    final resolved = await resolver.resolveSource('''
    class MyClass {
      void myMethod() {}
    }
    ''');

    final method = findMethodDeclaration(resolved.unit, 'nonExistingMethod');

    expect(method, isNull);
  });

  test('getMethodDeclaration returns method declaration if found', () async {
    final resolved = await resolver.resolveSource('''
    class MyClass {
      void myMethod() {}
    }
    ''');

    final method = getMethodDeclaration(resolved.unit, 'myMethod');

    expect(method, isNotNull);
  });

  test(
    'getMethodDeclaration fails if method declaration is not found',
    () async {
      final resolved = await resolver.resolveSource('''
    class MyClass {
      void myMethod() {}
    }
    ''');

      expect(
        () => getMethodDeclaration(resolved.unit, 'nonExistingMethod'),
        throwsA(isA<TestFailure>()),
      );
    },
  );
}
