import 'package:analysis_server_plugin_core/src/extensions/path_string_extensions.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';

extension RuleContextExtensions on RuleContext {
  /// The defining unit's path, relative to the package root,
  /// or null if the defining unit is not part of any package.
  ///
  /// e.g. `'/Users/foo/myproject/lib/bar.dart'` → `'lib/bar.dart'`
  /// e.g. `'C:\Users\foo\myproject\lib\bar.dart'` → `'lib/bar.dart'`
  ///
  /// > Note:
  /// > The path separators are always converted to `/` (i.e., forward slash).
  String? get packageRelativeUnitPath {
    final absPath = definingUnit.file.path;
    final packageRoot = package?.root.path;
    if (packageRoot == null) {
      return null;
    }

    final normalizedRoot = packageRoot.normalizePathSeparators;
    final normalizedPath = absPath.normalizePathSeparators;
    final prefix = normalizedRoot.endsWith('/')
        ? normalizedRoot
        : '$normalizedRoot/';

    if (!normalizedPath.startsWith(prefix)) {
      return null;
    }

    return normalizedPath.substring(prefix.length);
  }
}
