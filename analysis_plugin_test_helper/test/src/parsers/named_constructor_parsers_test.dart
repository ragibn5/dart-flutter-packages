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

  test(
    'findConstructorDeclarationShouldFindTheConstructorIfMixinsAndExtensionsComeFirst',
    () async {
      final result = await resolver.resolveSource('''
      mixin MyMixin {}

      extension MyExtension on int {}

      class MyClass {
        MyClass.named();
      }
      ''');

      expect(findConstructorDeclaration(result.unit, 'named'), isNotNull);
    },
  );

  test(
    'findConstructorDeclarationShouldFindTheConstructorIfItIsInAnExtensionType',
    () async {
      final result = await resolver.resolveSource('''
      extension type MyId(int value) {
        MyId.zero() : value = 0;
      }
      ''');

      expect(findConstructorDeclaration(result.unit, 'zero'), isNotNull);
    },
  );

  test(
    'findConstructorDeclarationShouldFindTheConstructorIfItIsInAnEnum',
    () async {
      final result = await resolver.resolveSource('''
      enum MyEnum {
        a.named();

        const MyEnum.named();
      }
      ''');

      expect(findConstructorDeclaration(result.unit, 'named'), isNotNull);
    },
  );

  test(
    'findConstructorDeclarationShouldReturnNullIfOnlyATopLevelFunctionHasTheName',
    () async {
      final result = await resolver.resolveSource('''
      void named() {}
      ''');

      expect(findConstructorDeclaration(result.unit, 'named'), isNull);
    },
  );

  test(
    'findFactoryConstructorDeclarationShouldFindTheFactoryIfMixinsAndExtensionsComeFirst',
    () async {
      final result = await resolver.resolveSource('''
      mixin MyMixin {}

      extension MyExtension on int {}

      class MyClass {
        MyClass();

        factory MyClass.fromMap(Map map) => MyClass();
      }
      ''');

      expect(
        findFactoryConstructorDeclaration(result.unit, 'fromMap'),
        isNotNull,
      );
    },
  );

  test(
    'findFactoryConstructorDeclarationShouldFindTheFactoryIfItIsInAnExtensionType',
    () async {
      final result = await resolver.resolveSource('''
      extension type MyId(int value) {
        factory MyId.zero() => MyId(0);
      }
      ''');

      expect(findFactoryConstructorDeclaration(result.unit, 'zero'), isNotNull);
    },
  );

  test(
    'findFactoryConstructorDeclarationShouldFindTheFactoryIfItIsInAnEnum',
    () async {
      final result = await resolver.resolveSource('''
      enum MyEnum {
        a;

        const MyEnum();

        factory MyEnum.first() => a;
      }
      ''');

      expect(
        findFactoryConstructorDeclaration(result.unit, 'first'),
        isNotNull,
      );
    },
  );

  test(
    'findFactoryConstructorDeclarationShouldReturnNullIfOnlyAPlainConstructorHasTheName',
    () async {
      final result = await resolver.resolveSource('''
      class MyClass {
        MyClass.fromMap(Map map);
      }
      ''');

      expect(findFactoryConstructorDeclaration(result.unit, 'fromMap'), isNull);
    },
  );

  test(
    'findFactoryConstructorDeclarationShouldReturnNullIfOnlyATopLevelFunctionHasTheName',
    () async {
      final result = await resolver.resolveSource('''
      void fromMap() {}
      ''');

      expect(findFactoryConstructorDeclaration(result.unit, 'fromMap'), isNull);
    },
  );
}
