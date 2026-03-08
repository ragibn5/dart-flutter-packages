// ignore_for_file: lines_longer_than_80_chars

import 'package:clean_arch_lint/src/models/import_uri.dart';
import 'package:clean_arch_lint/src/services/import_uri_builder/import_uri_builder.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '../../../utils/parsers/import_directive_parsers.dart';

void main() {
  late ImportUriBuilder sut;

  setUp(() {
    sut = ImportUriBuilder();
  });

  test('If uri string is empty or blank, or null, returns null', () {
    final importDirective = parseValidImportDirective("import '';");
    expect(sut.fromImportNode(importDirective), isNull);
  });

  test('If there is no `:`, the entire uri is just path', () {
    final importDirective = parseValidImportDirective("import 'a/b/c';");
    expect(
      sut.fromImportNode(importDirective),
      isA<ImportUri>()
          .having((p) => p.scheme, 'scheme', isNull)
          .having((p) => p.packageName, 'packageName', isNull)
          .having((p) => p.path, 'path', isNotNull)
          .having((p) => p.path, 'path', 'a/b/c'),
    );
  });

  test('If uri string has colon but missing mandatory parts, returns null', () {
    final invalidUris = [
      ':', // only colon
      'package:', // scheme only, no package/path
      ': ', // empty package/path
    ];

    for (final uri in invalidUris) {
      final importDirective = parseValidImportDirective("import '$uri';");
      expect(sut.fromImportNode(importDirective), isNull);
    }
  });

  test(
    'If uri string is of form `scheme:package/path`, returns correct ImportUri',
    () {
      final importDirective = parseValidImportDirective(
        "import 'package:foo/bar.dart';",
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

  test('If uri string is of form `scheme:package` (no /), path = package', () {
    final importDirective = parseValidImportDirective("import 'package:foo';");
    final result = sut.fromImportNode(importDirective);
    expect(
      result,
      isA<ImportUri>()
          .having((p) => p.scheme, 'scheme', 'package')
          .having((p) => p.packageName, 'packageName', isNull)
          .having((p) => p.path, 'path', 'foo'),
    );
  });

  test(
    'If uri string is of form `:package/path` (no scheme), returns correct ImportUri',
    () {
      final importDirective = parseValidImportDirective(
        "import ':foo/bar.dart';",
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
    () {
      final importDirective = parseValidImportDirective("import ':foo';");
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
    () {
      final importDirective = parseValidImportDirective("import 'package:';");
      expect(sut.fromImportNode(importDirective), isNull);
    },
  );

  test(
    'If uri string contains multiple colons, first colon is scheme separator',
    () {
      final importDirective = parseValidImportDirective("import 'x:y:z';");
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
