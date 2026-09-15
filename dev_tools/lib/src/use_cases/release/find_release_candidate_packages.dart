import 'package:dev_tools/src/models/package_info.dart';
import 'package:dev_tools/src/models/release_candidate_package.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/filter_touched_packages.dart';
import 'package:dev_tools/src/use_cases/release/fetch_pub_dev_package_info.dart';
import 'package:dev_tools/src/use_cases/release/package_registry_client.dart';

/// Narrows a set of already-resolved local packages down to release
/// candidates among a set of changed files.
///
/// A package is a release candidate when it was touched (per `changedFiles`,
/// e.g. from `DetectChangesInFolder`), is publishable (`PackageIdentity
/// .isPublishable` — false for e.g. an app or other internal package with
/// no version, or one opting out via `publish_to: none`; neither is an
/// error, just not releasable), and its current version is not yet
/// published on the package registry (covering both version bumps and
/// brand-new packages).
class FindReleaseCandidatePackages {
  final PackageRegistryClient _packageRegistryClient;
  final FilterTouchedPackages _filterTouchedPackages;

  const FindReleaseCandidatePackages({
    PackageRegistryClient packageRegistryClient =
        const FetchPubDevPackageInfo(),
    FilterTouchedPackages filterTouchedPackages = const FilterTouchedPackages(),
  })  : _packageRegistryClient = packageRegistryClient,
        _filterTouchedPackages = filterTouchedPackages;

  /// Finds release-candidate packages among [localPackages].
  ///
  /// Params:
  /// - `localPackages`: already-resolved local packages to consider (e.g.
  ///   from `FindPackages`) — this use case doesn't scan a repo itself.
  /// - `changedFiles`: repository-root-relative paths of touched files,
  ///   e.g. from `DetectChangesInFolder`.
  ///
  /// Returns: candidate packages, in no particular order.
  ///
  /// Throws:
  /// - [PackageRegistryLookupException] when the package registry cannot
  ///   be reached.
  Future<List<ReleaseCandidatePackage>> call({
    required List<ValidLocalPackageInfo> localPackages,
    required List<String> changedFiles,
  }) async {
    final touchedPackages = _filterTouchedPackages(
      localPackages: localPackages,
      changedFiles: changedFiles,
    );

    final candidates = <ReleaseCandidatePackage>[];
    for (final package in touchedPackages) {
      if (!package.packageIdentity.isPublishable) continue;

      // isPublishable guarantees a non-null version (see PackageIdentity).
      final version = package.packageIdentity.version!;
      final info = await _packageRegistryClient(package.packageIdentity.name);
      if (!info.versions.contains(version)) {
        candidates.add(
          ReleaseCandidatePackage(
            repoRootRelativePath: package.repoRootRelativePath,
            packageIdentity: package.packageIdentity,
            publishedPackageInfo: info,
          ),
        );
      }
    }
    return candidates;
  }
}
