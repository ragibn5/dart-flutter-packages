// ignore_for_file: lines_longer_than_80_chars

import 'package:analysis_plugin_test_helper/analysis_plugin_test_helper.dart';
import 'package:clean_arch_lint/src/models/import_uri.dart';
import 'package:clean_arch_lint/src/services/import_uri_builder/import_uri_builder.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  final dartResolver = DartUnitResolver();

  late ImportUriBuilder sut;

  setUpAll(() async {
    await dartResolver.setUp();
  });

  setUp(() {
    sut = ImportUriBuilder();
  });

  tearDownAll(() async {
    await dartResolver.tearDown();
  });

  test('If uri string is empty or blank, or null, returns null', () async {
    final importDirective = getImportDirective(
      (await dartResolver.resolveSource("import '';")).unit,
    );
    expect(sut.fromImportNode(importDirective), isNull);
  });

  test('If there is no `:`, the entire uri is just path', () async {
    final importDirective = getImportDirective(
      (await dartResolver.resolveSource("import 'a/b/c';")).unit,
    );
    expect(
      sut.fromImportNode(importDirective),
      isA<ImportUri>()
          .having((p) => p.scheme, 'scheme', isNull)
          .having((p) => p.packageName, 'packageName', isNull)
          .having((p) => p.path, 'path', isNotNull)
          .having((p) => p.path, 'path', 'a/b/c'),
    );
  });

  test(
    'If uri string has colon but missing mandatory parts, returns null',
    () async {
      final invalidUris = [
        ':', // only colon
        'package:', // scheme only, no package/path
        ': ', // empty package/path
      ];

      for (final uri in invalidUris) {
        final importDirective = getImportDirective(
          (await dartResolver.resolveSource("import '$uri';")).unit,
        );
        expect(sut.fromImportNode(importDirective), isNull);
      }
    },
  );

  test(
    'If uri string is of form `scheme:package/path`, returns correct ImportUri',
    () async {
      final importDirective = getImportDirective(
        (await dartResolver.resolveSource(
          "import 'package:foo/bar.dart';",
        )).unit,
      );
      final result = sut.fromImportNode(importDirective);
      expect(
        result,
        isA<ImportUri>()
            .having((p) => p.scheme, 'scheme', 'package')
            .having((p) => p.packageName, 'packageName', 'foo')
            .having((p) => p.path, 'path', 'bar.dart'),
      );
    },
  );

  test(
    'If uri string is of form `scheme:package` (no /), path = package',
    () async {
      final importDirective = getImportDirective(
        (await dartResolver.resolveSource("import 'package:foo';")).unit,
      );
      final result = sut.fromImportNode(importDirective);
      expect(
        result,
        isA<ImportUri>()
            .having((p) => p.scheme, 'scheme', 'package')
            .having((p) => p.packageName, 'packageName', isNull)
            .having((p) => p.path, 'path', 'foo'),
      );
    },
  );

  test(
    'If uri string is of form `:package/path` (no scheme), returns correct ImportUri',
    () async {
      final importDirective = getImportDirective(
        (await dartResolver.resolveSource("import ':foo/bar.dart';")).unit,
      );
      final result = sut.fromImportNode(importDirective);
      expect(
        result,
        isA<ImportUri>()
            .having((p) => p.scheme, 'scheme', isNull)
            .having((p) => p.packageName, 'packageName', 'foo')
            .having((p) => p.path, 'path', 'bar.dart'),
      );
    },
  );

  test(
    'If uri string is of form `:package` (no scheme, no /), path = package',
    () async {
      final importDirective = getImportDirective(
        (await dartResolver.resolveSource("import ':foo';")).unit,
      );
      final result = sut.fromImportNode(importDirective);
      expect(
        result,
        isA<ImportUri>()
            .having((p) => p.scheme, 'scheme', isNull)
            .having((p) => p.packageName, 'packageName', isNull)
            .having((p) => p.path, 'path', 'foo'),
      );
    },
  );

  test(
    'If uri string is of form `scheme:` (scheme only, no package or path), returns null',
    () async {
      final importDirective = getImportDirective(
        (await dartResolver.resolveSource("import 'package:';")).unit,
      );
      expect(sut.fromImportNode(importDirective), isNull);
    },
  );

  test(
    'If uri string contains multiple colons, first colon is scheme separator',
    () async {
      final importDirective = getImportDirective(
        (await dartResolver.resolveSource("import 'x:y:z';")).unit,
      );
      final result = sut.fromImportNode(importDirective);

      expect(
        result,
        isA<ImportUri>()
            .having((p) => p.scheme, 'scheme', 'x')
            .having((p) => p.packageName, 'packageName', isNull)
            .having((p) => p.path, 'path', 'y:z'),
      );
    },
  );
}
