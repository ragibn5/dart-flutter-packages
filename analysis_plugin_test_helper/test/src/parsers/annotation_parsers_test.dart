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

  test('findAnnotation returns null if not found', () async {
    final resolved = await resolver.resolveSource('''
    class MyAnnotation {
      const MyAnnotation();
    }

    class Foo {}
    ''');

    final annotation = findAnnotation(
      resolved.unit,
      annotationName: 'MyAnnotation',
    );

    expect(annotation, isNull);
  });

  test('findAnnotation returns annotation (inline)', () async {
    final resolved = await resolver.resolveSource('''
    class MyAnnotation {
      const MyAnnotation();
    }

    @MyAnnotation()
    class Foo {}
    ''');

    final annotation = findAnnotation(
      resolved.unit,
      annotationName: 'MyAnnotation',
    );

    expect(annotation, isNotNull);
  });

  test('findAnnotation returns annotation (const variable)', () async {
    final resolved = await resolver.resolveSource('''
    class MyAnnotation {
      const MyAnnotation();
    }
    
    const myAnn = MyAnnotation();

    @myAnn
    class Foo {}
    ''');

    final annotation = findAnnotation(
      resolved.unit,
      annotationName: 'MyAnnotation',
    );

    expect(annotation, isNotNull);
  });

  test('findAnnotation returns annotation (typedef)', () async {
    final resolved = await resolver.resolveSource('''
    class MyAnnotation {
      const MyAnnotation();
    }
    
    typedef MAN = MyAnnotation;

    @MAN()
    class Foo {}
    ''');

    final annotation = findAnnotation(
      resolved.unit,
      annotationName: 'MyAnnotation',
    );

    expect(annotation, isNotNull);
  });

  test('getAnnotation returns annotation if found', () async {
    final resolved = await resolver.resolveSource('''
    class MyAnnotation {
      const MyAnnotation();
    }

    @MyAnnotation()
    int get foo => 42;
    ''');

    final annotation = findAnnotation(
      resolved.unit,
      annotationName: 'MyAnnotation',
    );

    expect(annotation, isNotNull);
  });

  test('getAnnotation fails if annotation is not found', () async {
    final resolved = await resolver.resolveSource('''
    class MyAnnotation {
      const MyAnnotation();
    }

    class Foo {}
    ''');

    expect(
      () => getAnnotation(resolved.unit, annotationName: 'MyAnnotation'),
      throwsA(isA<TestFailure>()),
    );
  });
}
