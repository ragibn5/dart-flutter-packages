import 'package:dev_tools/src/models/package_info.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_packages.dart';

/// Finds every package in the repository.
class FindAllPackages {
  final FindPackages _findPackages;

  const FindAllPackages({
    FindPackages findPackages = const FindPackages(),
  }) : _findPackages = findPackages;

  /// Params:
  /// - `repoRoot`: absolute path to the repository root to scan.
  /// - `skipPaths`: repo-root-relative path prefixes of whole packages to
  ///   skip entirely.
  ///
  /// Returns: every found [ValidLocalPackageInfo], in no particular order.
  ///
  /// Throws:
  /// - [PackageFinderException] while scanning for packages (see
  ///   [FindPackages]).
  Future<List<ValidLocalPackageInfo>> call({
    required String repoRoot,
    List<String> skipPaths = const [],
  }) async {
    final foundPackages = await _findPackages(repoRoot: repoRoot);
    return foundPackages
        .whereType<ValidLocalPackageInfo>()
        .where((pkg) => !_isSkipped(pkg.repoRootRelativePath, skipPaths))
        .toList();
  }

  bool _isSkipped(String repoRootRelativePath, List<String> skipPaths) =>
      skipPaths.any(
        (prefix) =>
            repoRootRelativePath == prefix ||
            repoRootRelativePath.startsWith('$prefix/'),
      );
}
