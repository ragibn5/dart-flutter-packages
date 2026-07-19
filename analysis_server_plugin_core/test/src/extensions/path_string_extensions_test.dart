import 'package:analysis_server_plugin_core/src/extensions/path_string_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('normalizePathSeparators', () {
    test('Should replace backslashes with forward slashes', () {
      expect(r'lib\core\utils'.normalizePathSeparators, 'lib/core/utils');
    });

    test('Should replace forward slashes with forward slashes (no-op)', () {
      expect('lib/core/utils'.normalizePathSeparators, 'lib/core/utils');
    });

    test('Should handle mixed separators', () {
      expect(
        r'lib\core/utils'.normalizePathSeparators,
        'lib/core/utils',
      );
    });

    test('Should handle a single backslash', () {
      expect(r'a\b'.normalizePathSeparators, 'a/b');
    });

    test('Should handle an empty string', () {
      expect(''.normalizePathSeparators, '');
    });

    test('Should handle a string with no separators', () {
      expect('filename.dart'.normalizePathSeparators, 'filename.dart');
    });

    test('Should handle trailing separator', () {
      expect('lib/core/'.normalizePathSeparators, 'lib/core/');
    });

    test('Should handle Windows-style absolute path', () {
      expect(
        r'C:\Users\foo\project\lib\bar.dart'.normalizePathSeparators,
        'C:/Users/foo/project/lib/bar.dart',
      );
    });
  });

  group('ensureTrailingPathSeparator', () {
    test('Should add trailing slash when missing', () {
      expect('lib/core'.ensureTrailingPathSeparator, 'lib/core/');
    });

    test('Should not add trailing slash when already present', () {
      expect('lib/core/'.ensureTrailingPathSeparator, 'lib/core/');
    });

    test('Should handle empty string', () {
      expect(''.ensureTrailingPathSeparator, '/');
    });

    test('Should handle single character string', () {
      expect('a'.ensureTrailingPathSeparator, 'a/');
    });
  });

  group('surroundingPathSeparator', () {
    test('Should add leading and trailing slashes when neither present', () {
      expect('domain'.surroundingPathSeparator, '/domain/');
    });

    test('Should add leading slash only', () {
      expect('domain/'.surroundingPathSeparator, '/domain/');
    });

    test('Should add trailing slash only', () {
      expect('/domain'.surroundingPathSeparator, '/domain/');
    });

    test('Should not modify when both slashes already present', () {
      expect('/domain/'.surroundingPathSeparator, '/domain/');
    });

    test('Should handle empty string', () {
      expect(''.surroundingPathSeparator, '/');
    });

    test('Should handle nested path', () {
      expect('lib/core'.surroundingPathSeparator, '/lib/core/');
    });
  });
}
