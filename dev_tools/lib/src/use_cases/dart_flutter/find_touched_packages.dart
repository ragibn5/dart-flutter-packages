import 'package:dev_tools/src/models/package_info.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/filter_touched_packages.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_packages.dart';
import 'package:dev_tools/src/use_cases/git/detect_changes_in_folder.dart';

/// Finds every package touched between two git refs.
class FindTouchedPackages {
  final FindPackages _findPackages;
  final DetectChangesInFolder _detectChangesInFolder;
  final FilterTouchedPackages _filterTouchedPackages;

  const FindTouchedPackages({
    FindPackages findPackages = const FindPackages(),
    DetectChangesInFolder detectChangesInFolder = const DetectChangesInFolder(),
    FilterTouchedPackages filterTouchedPackages = const FilterTouchedPackages(),
  })  : _findPackages = findPackages,
        _detectChangesInFolder = detectChangesInFolder,
        _filterTouchedPackages = filterTouchedPackages;

  /// Params:
  /// - `repoRoot`: absolute path to the repository root to scan.
  /// - `fromRef`: the ref to diff from, i.e. the branch's state before this
  ///   change.
  /// - `toRef`: the ref to diff against, i.e. the branch's state after this
  ///   change.
  /// - `skipPaths`: repo-root-relative path prefixes of whole packages to
  ///   skip entirely.
  ///
  /// Returns: every touched [ValidLocalPackageInfo], in no particular
  /// order.
  ///
  /// Throws:
  /// - [PackageFinderException] while scanning for packages (see
  ///   [FindPackages]).
  /// - [GitDiffingException] when `git diff` fails.
  Future<List<ValidLocalPackageInfo>> call({
    required String repoRoot,
    required String fromRef,
    required String toRef,
    List<String> skipPaths = const [],
  }) async {
    final foundPackages = await _findPackages(repoRoot: repoRoot);
    final validPackages = foundPackages
        .whereType<ValidLocalPackageInfo>()
        .where((pkg) => !_isSkipped(pkg.repoRootRelativePath, skipPaths))
        .toList();

    final changedFiles = await _detectChangesInFolder(
      baseRef: fromRef,
      compareRef: toRef,
    );
    return _filterTouchedPackages(
      localPackages: validPackages,
      changedFiles: changedFiles,
    );
  }

  bool _isSkipped(String repoRootRelativePath, List<String> skipPaths) =>
      skipPaths.any(
        (prefix) =>
            repoRootRelativePath == prefix ||
            repoRootRelativePath.startsWith('$prefix/'),
      );
}
