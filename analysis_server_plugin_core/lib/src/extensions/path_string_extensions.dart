extension PathStringExtensions on String {
  /// Replaces all path separators with `/`.
  ///
  /// e.g. `'lib\core\utils'` → `'lib/core/utils'`
  String get normalizePathSeparators {
    return replaceAll(RegExp(r'[\\/]'), '/');
  }

  /// Ensures the path ends with a trailing `/`.
  ///
  /// e.g. `'lib/core'` → `'lib/core/'`
  /// e.g. `'lib/core/'` → `'lib/core/'` (unchanged)
  ///
  /// > Note: This method does not transform the original string in any way.
  /// > It only ensures the string ends with a trailing `/` (if not already).
  /// > If you need to do any transformation on the original string, like trim
  /// > or normalize the path separators, you need to do that manually. You may
  /// > use the [normalizePathSeparators] to normalize the path separators if
  /// > you need to.
  String get ensureTrailingPathSeparator {
    return endsWith('/') ? this : '$this/';
  }

  /// Wraps this string with `/` on both sides to match as a full path segment.
  ///
  /// e.g. `'domain'` → `'/domain/'`
  /// e.g. `'/domain/'` → `'/domain/'` (unchanged)
  ///
  /// > Note: This method does not transform the original string in any way.
  /// > It only ensures the string is surrounded by `/` (if not already).
  /// > If you need to do any transformation on the original string, like trim
  /// > or normalize the path separators, you need to do that manually. You may
  /// > use the [normalizePathSeparators] to normalize the path separators if
  /// > you need to.
  String get surroundingPathSeparator {
    var result = this;
    if (!result.startsWith('/')) {
      result = '/$result';
    }
    if (!result.endsWith('/')) {
      result = '$result/';
    }
    return result;
  }
}
