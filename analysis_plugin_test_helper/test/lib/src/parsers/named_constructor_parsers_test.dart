import 'package:analysis_plugin_test_helper/analysis_plugin_test_helper.dart';
import 'package:test/test.dart';

void main() {
  final DartUnitResolver resolver = DartUnitResolver();

  setUpAll(() async {
    await resolver.setUp();
  });

  tearDownAll(() async {
    await resolver.tearDown();
  });

  test('findConstructorDeclaration returns constructor declaration', () async {
    final result = await resolver.resolveSource('''
    class MyClass {
      MyClass(int value);
      
      MyClass.named(String name);
    }
    ''');

    final constructorNamed = findConstructorDeclaration(result.unit, 'named');

    expect(constructorNamed, isNotNull);
  });

  test(
    'findFactoryConstructorDeclaration returns factory constructor declaration',
    () async {
      final result = await resolver.resolveSource('''
      class MyClass {
        MyClass(int value);
        
        factory MyClass.fromMap(Map map) => MyClass(0);
      }
      ''');

      final constructorFromMap = findConstructorDeclaration(
        result.unit,
        'fromMap',
      );

      expect(constructorFromMap, isNotNull);
    },
  );

  test('findConstructorDeclaration returns null if not found', () async {
    final result = await resolver.resolveSource('''
    class MyClass {
      MyClass(int value);
    }
    ''');

    final constructor = findConstructorDeclaration(result.unit, 'named');

    expect(constructor, isNull);
  });

  test('findFactoryConstructorDeclaration returns null if not found', () async {
    final result = await resolver.resolveSource('''
    class MyClass {
      MyClass(int value);
    }
    ''');

    final constructor = findFactoryConstructorDeclaration(
      result.unit,
      'fromMap',
    );

    expect(constructor, isNull);
  });

  test(
    'getConstructorDeclaration returns constructor declaration if found',
    () async {
      final result = await resolver.resolveSource('''
      class MyClass {
        MyClass.named(String name);
      }
      ''');

      final constructor = getConstructorDeclaration(result.unit, 'named');

      expect(constructor, isNotNull);
    },
  );

  test(
    'getConstructorDeclaration fails if constructor declaration is not found',
    () async {
      final result = await resolver.resolveSource('''
      class MyClass {
        MyClass(int value);
      }
      ''');

      expect(
        () => getConstructorDeclaration(result.unit, 'named'),
        throwsA(isA<TestFailure>()),
      );
    },
  );

  test(
    'getFactoryConstructorDeclaration returns factory constructor declaration if found',
    () async {
      final result = await resolver.resolveSource('''
      class MyClass {
        factory MyClass.fromMap(Map map) => MyClass(0);
      }
      ''');

      final constructor = getFactoryConstructorDeclaration(
        result.unit,
        'fromMap',
      );

      expect(constructor, isNotNull);
    },
  );

  test(
    'getFactoryConstructorDeclaration fails if factory constructor declaration is not found',
    () async {
      final result = await resolver.resolveSource('''
      class MyClass {
        MyClass(int value);
      }
      ''');

      expect(
        () => getFactoryConstructorDeclaration(result.unit, 'fromMap'),
        throwsA(isA<TestFailure>()),
      );
    },
  );
}
