import 'package:analysis_server_plugin_core/src/extensions/path_string_extensions.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';

extension RuleContextExtensions on RuleContext {
  /// The defining unit's path, relative to the package root,
  /// or null if the defining unit is not part of any package.
  ///
  /// For example,
  /// - `'/Users/foo/myproject/lib/bar.dart'` → `'lib/bar.dart'`
  ///
  /// Returns null if:
  /// - [RuleContext.package] is null, or
  /// - the path is outside the package root.
  ///
  /// > Note: The returned path uses the given [pathSeparator] for
  /// > all separators, regardless of the platform's native separator.
  String? packageRelativeUnitPath({required String pathSeparator}) {
    final absPath = definingUnit.file.path;
    final packageRoot = package?.root.path;
    if (packageRoot == null) {
      return null;
    }

    final normalizedRoot = packageRoot.normalizePathSeparators(
      pathSeparator: pathSeparator,
    );
    final normalizedPath = absPath.normalizePathSeparators(
      pathSeparator: pathSeparator,
    );
    final prefix = normalizedRoot.endsWith(pathSeparator)
        ? normalizedRoot
        : '$normalizedRoot$pathSeparator';

    if (!normalizedPath.startsWith(prefix)) {
      return null;
    }

    return normalizedPath.substring(prefix.length);
  }
}
