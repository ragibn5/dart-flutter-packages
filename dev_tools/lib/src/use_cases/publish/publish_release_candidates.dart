import 'package:dev_tools/src/models/release_candidate_package.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/resolve_local_packages.dart';
import 'package:dev_tools/src/use_cases/git/create_and_push_tag.dart';
import 'package:dev_tools/src/use_cases/git/get_tag_format.dart';
import 'package:dev_tools/src/use_cases/publish/publish_batch_exception.dart';
import 'package:dev_tools/src/use_cases/publish/run_publish_flow.dart';
import 'package:dev_tools/src/use_cases/release/fetch_pub_dev_package_info.dart';
import 'package:dev_tools/src/use_cases/release/package_registry_client.dart';
import 'package:dev_tools/src/utils/logger.dart';

/// Result of attempting to publish every release candidate: the tag each
/// successfully published one got, and the error for every one that failed.
/// ignore: avoid_private_typedef_functions
typedef _PublishResult = ({
  Map<String, String> published,
  Map<String, String> issueMap,
});

/// Orchestrates publishing every eligible release candidate among a given
/// set of packages, and tagging each one that publishes successfully.
///
/// A given package is an eligible candidate when it's publishable
/// (`PackageIdentity.isPublishable` — false for e.g. an app or other
/// internal package with no version, or one opting out via
/// `publish_to: none`) and its current version isn't already published on
/// the package registry; neither exclusion is an error, just not something
/// to publish.
///
/// Runs independently per candidate — one failing doesn't stop the rest —
/// then reports a per-package summary and fails the batch (via
/// [PublishBatchException]) if any candidate failed.
class PublishReleaseCandidates {
  final Logger _logger;
  final GetTagFormat _gitTagFormat;
  final CreateAndPushTag _createAndPushTag;
  final ResolveLocalPackages _resolveLocalPackages;
  final PackageRegistryClient _packageRegistryClient;
  final RunPublishFlow _runPublishFlow;

  const PublishReleaseCandidates({
    Logger logger = const ConsoleLogger(),
    GetTagFormat gitTagFormat = const GetTagFormat(ResolveGitTagFormat()),
    CreateAndPushTag createAndPushTag = const CreateAndPushTag(),
    ResolveLocalPackages resolveLocalPackages = const ResolveLocalPackages(),
    PackageRegistryClient packageRegistryClient =
        const FetchPubDevPackageInfo(),
    RunPublishFlow runPublishFlow = const RunPublishFlow(),
  })  : _logger = logger,
        _resolveLocalPackages = resolveLocalPackages,
        _packageRegistryClient = packageRegistryClient,
        _runPublishFlow = runPublishFlow,
        _gitTagFormat = gitTagFormat,
        _createAndPushTag = createAndPushTag;

  /// Publishes every eligible release candidate among [packagePaths],
  /// tagging each one that publishes successfully.
  ///
  /// Params:
  /// - `repoRoot`: absolute path to the repository root.
  /// - `packagePaths`: repo-root-relative paths of the packages to consider
  ///   (e.g. `packages/foo`) — every entry must resolve to a package with a
  ///   valid pubspec.yaml under [repoRoot].
  /// - `dryRun`: when true, run each candidate's dry-run publish only —
  ///   nothing is actually published, and no tags are created or pushed.
  ///
  /// Returns: nothing (void) when every candidate published successfully.
  ///
  /// Throws:
  /// - [PackageNotFoundException] when a package path doesn't resolve to a
  ///   package with a valid pubspec.yaml.
  /// - [PackageRegistryLookupException] while narrowing candidates.
  /// - [PublishBatchException] listing every candidate that failed to
  ///   publish or tag, once all candidates have been attempted.
  Future<void> call({
    required String repoRoot,
    required List<String> packagePaths,
    bool dryRun = false,
  }) async {
    final candidates = await _logger.withGroupedLog(
      'Resolving release candidates...',
      (logger) => _extractReleaseCandidates(repoRoot, packagePaths, logger),
    );

    final results =
        await _publishCandidates(repoRoot, candidates, dryRun: dryRun);
    _logger.info(
      'Attempted ${candidates.length} release candidate(s):\n'
      '${_buildSummary(results.published, results.issueMap, dryRun: dryRun)}',
    );

    if (results.issueMap.isNotEmpty) {
      final verb = dryRun ? 'dry-run publish' : 'publish';
      throw PublishBatchException(
        '${results.issueMap.length} release candidate(s) failed to '
        '$verb.',
      );
    }
  }

  Future<List<ReleaseCandidatePackage>> _extractReleaseCandidates(
    String repoRoot,
    List<String> packagePaths,
    Logger logger,
  ) async {
    final packages = await _resolveLocalPackages(
      repoRoot: repoRoot,
      packagePaths: packagePaths,
    );

    final candidates = <ReleaseCandidatePackage>[];
    for (final package in packages) {
      final identity = package.packageIdentity;
      if (!identity.isPublishable) {
        logger.info('${package.repoRootRelativePath}: not publishable.');
        continue;
      }

      // isPublishable guarantees a non-null version.
      final version = identity.version!;
      final info = await _packageRegistryClient(identity.name);
      if (info.versions.contains(version)) {
        logger.info(
          '${package.repoRootRelativePath}: $version already published.',
        );
        continue;
      }

      candidates.add(
        ReleaseCandidatePackage(
          repoRootRelativePath: package.repoRootRelativePath,
          packageIdentity: identity,
          publishedPackageInfo: info,
        ),
      );
    }

    if (candidates.isEmpty) {
      logger.info('No release candidates found; nothing to publish.');
    } else {
      logger.info('Found ${candidates.length} release candidate(s).');
    }

    return candidates;
  }

  Future<_PublishResult> _publishCandidates(
    String repoRoot,
    List<ReleaseCandidatePackage> candidates, {
    required bool dryRun,
  }) async {
    final published = <String, String>{};
    final issuesMap = <String, String>{};
    for (var i = 0; i < candidates.length; ++i) {
      final candidate = candidates[i];
      final name = candidate.packageIdentity.name;
      await _logger.withGroupedLog(
        '[${i + 1}/${candidates.length}] Publishing $name ...',
        (logger) async {
          try {
            published[name] =
                await _publishCandidate(candidate, repoRoot, dryRun: dryRun);
          } catch (e) {
            issuesMap[name] = e.toString();
          }
        },
      );
    }

    return (published: published, issueMap: issuesMap);
  }

  Future<String> _publishCandidate(
    ReleaseCandidatePackage candidate,
    String repoRoot, {
    required bool dryRun,
  }) async {
    final identity = candidate.packageIdentity;
    // A ReleaseCandidatePackage is only ever built for a publishable
    // (hence versioned) package (see _extractReleaseCandidates above), so
    // this is never null here.
    final tag = _gitTagFormat(name: identity.name, version: identity.version!);

    // dryRunOnly follows the batch's own dryRun flag rather than
    // RunPublishFlow's default — a dry run here must never actually
    // publish, and tagging (below) must never run against one either.
    await _runPublishFlow(
      repoRoot: repoRoot,
      pkgPath: candidate.repoRootRelativePath,
      interactive: false,
      dryRunOnly: dryRun,
    );
    if (!dryRun) {
      await _createAndPushTag(tag, repoRoot: repoRoot);
    }
    return tag;
  }

  String _buildSummary(
    Map<String, String> published,
    Map<String, String> issuesMap, {
    required bool dryRun,
  }) {
    const tick = '✅';
    const cross = '❌';
    return [
      for (final entry in published.entries) ...[
        if (dryRun)
          '  $tick ${entry.key}: dry-run publish passed'
        else ...[
          '  $tick ${entry.key}: published',
          '  $tick ${entry.key}: tagged (${entry.value})',
        ],
      ],
      for (final entry in issuesMap.entries) ...[
        '  $cross ${entry.key}:',
        for (final line in entry.value.split('\n')) '      $line',
      ],
    ].join('\n');
  }
}
