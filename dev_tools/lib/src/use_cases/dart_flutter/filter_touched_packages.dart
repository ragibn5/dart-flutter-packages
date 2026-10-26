import 'package:dev_tools/src/models/package_info.dart';
import 'package:path/path.dart' as p;

/// Narrows a set of already-resolved local packages down to the ones
/// touched by a set of changed files.
class FilterTouchedPackages {
  const FilterTouchedPackages();

  /// Params:
  /// - `localPackages`: already-resolved local packages to consider (e.g.
  ///   from `FindPackages`) — this use case doesn't scan a repo itself.
  /// - `changedFiles`: repository-root-relative paths of touched files,
  ///   e.g. from `DetectChangesInFolder`.
  ///
  /// Returns: the packages among [localPackages] whose directory is, or
  /// contains, one of [changedFiles].
  List<ValidLocalPackageInfo> call({
    required List<ValidLocalPackageInfo> localPackages,
    required List<String> changedFiles,
  }) {
    return localPackages
        .where((pkg) => _isTouched(pkg.repoRootRelativePath, changedFiles))
        .toList();
  }

  bool _isTouched(String packageRelPath, List<String> changedFiles) {
    return changedFiles.any(
      (file) =>
          p.equals(file, packageRelPath) || p.isWithin(packageRelPath, file),
    );
  }
}
