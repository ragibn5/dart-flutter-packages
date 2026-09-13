import 'dart:io';

import 'package:dev_tools/src/models/package_info.dart';
import 'package:dev_tools/src/models/release_candidate_package.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_packages.dart';
import 'package:dev_tools/src/use_cases/git/create_and_push_tag.dart';
import 'package:dev_tools/src/use_cases/git/detect_changes_in_folder.dart';
import 'package:dev_tools/src/use_cases/git/get_tag_format.dart';
import 'package:dev_tools/src/use_cases/publish/publish_batch_exception.dart';
import 'package:dev_tools/src/use_cases/publish/run_publish_flow.dart';
import 'package:dev_tools/src/use_cases/release/find_release_candidate_packages.dart';
import 'package:dev_tools/src/use_cases/release/package_registry_client.dart';
import 'package:dev_tools/src/utils/logger.dart';

const _greenTick = '\x1B[32m✓\x1B[0m';
const _redCross = '\x1B[31m✗\x1B[0m';

/// Result of scanning the repo for packages, split by validity.
typedef _PackageScanResult = ({
  List<ValidLocalPackageInfo> valid,
  List<MalformedLocalPackageInfo> malformed,
});

/// Result of attempting to publish every release candidate: the tag each
/// successfully published one got, and the error for every one that failed.
/// ignore: avoid_private_typedef_functions
typedef _PublishResult = ({
  Map<String, String> published,
  Map<String, String> issuesByName,
});

/// Orchestrates publishing every release candidate introduced by a merge to
/// the release branch (e.g. `main`), and tagging each one that publishes
/// successfully.
///
/// Runs independently per candidate — one failing doesn't stop the rest —
/// then reports a per-package summary and fails the batch (via
/// [PublishBatchException]) if any candidate failed.
class PublishReleaseCandidates {
  final Logger _logger;
  final GetTagFormat _gitTagFormat;
  final CreateAndPushTag _createAndPushTag;
  final DetectChangesInFolder _detectChangesInFolder;
  final FindPackages _findPackages;
  final FindReleaseCandidatePackages _findReleaseCandidates;
  final RunPublishFlow _runPublishFlow;

  const PublishReleaseCandidates({
    Logger logger = const ConsoleLogger(),
    GetTagFormat gitTagFormat = const GetTagFormat(ResolveGitTagFormat()),
    CreateAndPushTag createAndPushTag = const CreateAndPushTag(),
    DetectChangesInFolder detectChangesInFolder = const DetectChangesInFolder(),
    FindPackages findPackages = const FindPackages(),
    FindReleaseCandidatePackages findReleaseCandidatePackages =
        const FindReleaseCandidatePackages(),
    RunPublishFlow runPublishFlow = const RunPublishFlow(),
  })  : _logger = logger,
        _detectChangesInFolder = detectChangesInFolder,
        _findPackages = findPackages,
        _findReleaseCandidates = findReleaseCandidatePackages,
        _runPublishFlow = runPublishFlow,
        _gitTagFormat = gitTagFormat,
        _createAndPushTag = createAndPushTag;

  /// Publishes every release candidate introduced between `fromRef` and
  /// `toRef`, tagging each one that publishes successfully.
  ///
  /// Params:
  /// - `repoRoot`: absolute path to the repository root.
  /// - `fromRef`: the ref to diff from, i.e. the release branch's state
  ///   before this merge (e.g. the previous `main` commit).
  /// - `toRef`: the ref to diff against, i.e. the release branch's state
  ///   after this merge (e.g. `HEAD`).
  /// - `dryRun`: when true, run each candidate's dry-run publish only —
  ///   nothing is actually published, and no tags are created or pushed.
  ///
  /// Returns: nothing (void) when every candidate published successfully.
  ///
  /// Throws:
  /// - [GitDiffingException] when `git diff` fails.
  /// - [PackageFinderException] while scanning for packages (see
  ///   [FindPackages]).
  /// - [PackageRegistryLookupException] while narrowing candidates (see
  ///   [FindReleaseCandidatePackages]).
  /// - [PublishBatchException] listing every candidate that failed to
  ///   publish or tag, once all candidates have been attempted.
  Future<void> call({
    required String repoRoot,
    required String fromRef,
    required String toRef,
    bool dryRun = false,
  }) async {
    final packages = await _logger.withGroupedLog(
      'Scanning for packages...',
      (logger) => _extractPackages(repoRoot, logger),
    );
    final candidates = await _logger.withGroupedLog(
      'Filtering release candidates...',
      (logger) => _extractReleaseCandidates(fromRef, toRef, packages, logger),
    );

    final results =
        await _publishCandidates(repoRoot, candidates, dryRun: dryRun);
    _logger.info(
      'Attempted ${candidates.length} release candidate(s):\n'
      '$_buildSummary(results.published, results.issuesByName, dryRun: dryRun)',
    );

    if (results.issuesByName.isNotEmpty) {
      final verb = dryRun ? 'dry-run publish' : 'publish';
      throw PublishBatchException(
        '${results.issuesByName.length} release candidate(s) failed to '
        '$verb.',
      );
    }
  }

  Future<_PackageScanResult> _extractPackages(
    String repoRoot,
    Logger logger,
  ) async {
    final foundPackages = await _findPackages(repoRoot: repoRoot);
    final validPackages =
        foundPackages.whereType<ValidLocalPackageInfo>().toList();
    final malformedPackages =
        foundPackages.whereType<MalformedLocalPackageInfo>().toList();

    logger
      ..info('Found ${foundPackages.length} package(s)')
      ..info('  Valid: ${validPackages.length}')
      ..info('  Malformed: ${malformedPackages.length}')
      ..info(
        malformedPackages
            .map((e) => '  - ${e.repoRootRelativePath}: ${e.reason}')
            .join('\n')
            .trim(),
      );

    return (valid: validPackages, malformed: malformedPackages);
  }

  Future<List<ReleaseCandidatePackage>> _extractReleaseCandidates(
    String fromRef,
    String toRef,
    _PackageScanResult packages,
    Logger logger,
  ) async {
    final changedFiles = await _detectChangesInFolder(
      baseRef: fromRef,
      compareRef: toRef,
    );
    final candidates = await _findReleaseCandidates(
      localPackages: packages.valid,
      changedFiles: changedFiles,
    );

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

    return (published: published, issuesByName: issuesMap);
  }

  Future<String> _publishCandidate(
    ReleaseCandidatePackage candidate,
    String repoRoot, {
    required bool dryRun,
  }) async {
    final identity = candidate.packageIdentity;
    // A ReleaseCandidatePackage is only ever built for a versioned package
    // (see FindReleaseCandidatePackages), so this is never null here.
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
    final tick = stdout.supportsAnsiEscapes ? _greenTick : '✓';
    final cross = stdout.supportsAnsiEscapes ? _redCross : '✗';
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
