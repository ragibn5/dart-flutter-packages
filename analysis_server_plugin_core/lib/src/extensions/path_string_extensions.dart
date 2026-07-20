extension PathStringExtensions on String {
  /// Replaces all path separators (of any platform) within this [String]
  /// with the given [pathSeparator].
  ///
  /// For example. if [pathSeparator] is `/`, calling this method on
  /// `'lib\core\utils\'` will produce the result `'lib/core/utils/'`
  String normalizePathSeparators({required String pathSeparator}) {
    return replaceAll(RegExp(r'[\\/]'), pathSeparator);
  }

  /// Ensures that the path ends with the given [pathSeparator].
  ///
  /// For example,
  /// - `'lib/core'` → `'lib/core/'`
  /// - `'lib/core/'` → `'lib/core/'` (unchanged)
  ///
  /// > Note: This method does not transform the original string in any way.
  /// > It only ensures that the string ends with the given [pathSeparator],
  /// > if not already.
  /// > If you need to do any transformation on the original string, like
  /// > trim or normalize the existing path separators, you need to do that
  /// > manually. You may use [normalizePathSeparators] to normalize the path
  /// > separators beforehand - if you need to.
  String ensureTrailingPathSeparator({required String pathSeparator}) {
    return endsWith(pathSeparator) ? this : '$this$pathSeparator';
  }

  /// Wraps this string with the given [pathSeparator], on both sides.
  ///
  /// For example,
  /// - `'domain'` → `'/domain/'`
  /// - `'domain/'` → `'/domain/'`
  /// - `'/domain'` → `'/domain/'`
  /// - `'/domain/'` → `'/domain/'` (unchanged)
  ///
  /// > Note: This method does not transform the original string in any way.
  /// > It only ensures the string is surrounded by `/` (if not already).
  /// > If you need to do any transformation on the original string, like trim
  /// > or normalize the path separators, you need to do that manually. You may
  /// > use the [normalizePathSeparators] to normalize the path separators if
  /// > you need to.
  String surroundingPathSeparator({required String pathSeparator}) {
    var result = this;
    if (!result.startsWith(pathSeparator)) {
      result = '$pathSeparator$result';
    }
    if (!result.endsWith(pathSeparator)) {
      result = '$result$pathSeparator';
    }
    return result;
  }
}
