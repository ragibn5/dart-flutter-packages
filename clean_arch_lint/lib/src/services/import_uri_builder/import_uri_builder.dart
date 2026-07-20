import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_lint/src/models/import_uri.dart';
import 'package:extended_string/extended_string.dart';
import 'package:path/path.dart' as p;

class ImportUriBuilder {
  /// Parses an [ImportDirective] into an [ImportUri].
  ///
  /// [hostPath] is the package-root-relative path of the file/unit
  /// containing the import (e.g. `lib/feature/auth/domain/services/bar.dart`).
  /// It is used to resolve relative imports against the source file/unit.
  ///
  /// The resulting [ImportUri.path] is always a package-root-relative path
  /// (starting with `lib/` or `test/`).
  ///
  /// - Package imports: `package:myapp/feature/auth/foo.dart`
  ///   → path = `lib/feature/auth/foo.dart`
  ///
  /// - Relative imports (from hostPath `lib/feature/auth/services/bar.dart`):
  ///   `import '../domain/models/baz.dart'`
  ///   → path = `lib/feature/auth/domain/models/baz.dart`
  ImportUri? fromImportNode(ImportDirective node, {required String hostPath}) {
    final uriString = node.uri.stringValue?.trim().nullOnEmptyOrBlank;

    // Case 1: empty/null (after trimming)
    if (uriString == null) {
      return null;
    }

    // Case 2: no colon — relative import, resolve against source
    if (!uriString.contains(':')) {
      final resolved = p.normalize(p.join(p.dirname(hostPath), uriString));
      return ImportUri(
        path: resolved.normalizePathSeparators(pathSeparator: '/'),
      );
    }

    // Case 3: colon exists, parse scheme:pkg/path or scheme:path
    //
    // For `package:a/b/c.dart`:
    //   group(1) = 'package' (scheme)
    //   group(2) = 'a'       (package name, stops at first /)
    //   group(3) = 'b/c.dart'(path within the package)
    //
    // For `dart:core`:
    //   group(1) = 'dart'
    //   group(2) = 'core'    (no group(3), so treated as path)
    final match = RegExp(r'^([^:]*):([^/]+)(?:/(.*))?$').firstMatch(uriString);
    if (match == null) {
      return null;
    }

    final scheme = match.group(1)?.trim().nullOnEmptyOrBlank;
    final packageNameOrPath = match.group(2)!;
    final subPath = match.group(3)?.trim().nullOnEmptyOrBlank;

    // `package:` imports must always have a package name and a path.
    // e.g. `package:foo` is malformed — return null.
    if (scheme == 'package' && subPath == null) {
      return null;
    }

    String? packageName;
    String path;
    if (subPath == null) {
      // No '/' after the segment — treat the whole thing as path.
      // e.g. `dart:core` → scheme='dart', path='core'
      packageName = null;
      path = packageNameOrPath;
    } else {
      packageName = packageNameOrPath;
      path = subPath;
    }

    // Normalize package imports to absolute package-relative paths.
    if (scheme == 'package' && packageName != null) {
      path = p.join('lib', path).normalizePathSeparators(pathSeparator: '/');
    }

    return ImportUri(scheme: scheme, packageName: packageName, path: path);
  }
}
