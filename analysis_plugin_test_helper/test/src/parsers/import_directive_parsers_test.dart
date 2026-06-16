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

  test('findImportDirective returns import directive', () async {
    final resolved = await resolver.resolveSource("import 'dart:async';");

    final import = findImportDirective(resolved.unit);

    expect(import, isNotNull);
  });

  test('findImportDirective returns null if not found', () async {
    final resolved = await resolver.resolveSource('class Foo {}');

    final import = findImportDirective(resolved.unit);

    expect(import, isNull);
  });

  test('getImportDirective returns import directive if found', () async {
    final resolved = await resolver.resolveSource("import 'dart:async';");

    final import = getImportDirective(resolved.unit);

    expect(import, isNotNull);
  });

  test('getImportDirective fails if import directive is not found', () async {
    final resolved = await resolver.resolveSource('class Foo {}');

    expect(
      () => getImportDirective(resolved.unit),
      throwsA(isA<TestFailure>()),
    );
  });
}
