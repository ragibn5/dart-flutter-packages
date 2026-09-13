import 'dart:io';

/// Reads a package's own coverage exclusion patterns, so each package can
/// exclude generated/boilerplate files from its coverage threshold without
/// a shared, repo-wide default list — every package's exclusions differ.
class ReadCoverageExclusions {
  const ReadCoverageExclusions();

  /// Params:
  /// - `packagePath`: absolute path to the package.
  ///
  /// Returns: lcov glob patterns from `<packagePath>/.coverage_exclude`, one
  /// per line — blank lines and `#`-prefixed comments are ignored. An empty
  /// list when the file doesn't exist.
  Future<List<String>> call(String packagePath) async {
    final file = File('$packagePath/.coverage_exclude');
    if (!file.existsSync()) {
      return const [];
    }

    return file
        .readAsLinesSync()
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('#'))
        .toList();
  }
}
