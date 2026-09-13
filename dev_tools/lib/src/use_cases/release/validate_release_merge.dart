import 'dart:io';

import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/models/release_candidate_package.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_packages.dart';
import 'package:dev_tools/src/use_cases/git/detect_changes_in_folder.dart';
import 'package:dev_tools/src/use_cases/git/get_tag_format.dart';
import 'package:dev_tools/src/use_cases/git/tag_exists.dart';
import 'package:dev_tools/src/use_cases/publish/package_publisher.dart';
import 'package:dev_tools/src/use_cases/publish/publish_failed_exception.dart';
import 'package:dev_tools/src/use_cases/release/find_release_candidate_packages.dart';
import 'package:dev_tools/src/use_cases/release/package_registry_client.dart';
import 'package:dev_tools/src/use_cases/release/release_validation_exception.dart';
import 'package:dev_tools/src/use_cases/release/standard_release_checks_builder.dart';
import 'package:dev_tools/src/use_cases/release/verify_release_completeness.dart';
import 'package:dev_tools/src/use_cases/release/verify_versioned_files.dart';
import 'package:dev_tools/src/utils/logger.dart';
import 'package:path/path.dart' as p;

const _greenTick = '\x1B[32m✓\x1B[0m';
const _redCross = '\x1B[31m✗\x1B[0m';

/// Orchestrates the MR-to-target-branch release gate end to end.
class ValidateReleaseMerge {
  final Logger _logger;
  final TagExists _tagExists;
  final GetTagFormat _gitTagFormat;
  final DetectChangesInFolder _detectChangesInFolder;
  final FindReleaseCandidatePackages _findReleaseCandidates;
  final VerifyReleaseCompleteness _verifyReleaseCompleteness;
  final BuildStandardReleaseChecksBuilder _standardReleaseChecksBuilder;
  final PackagePublisher _publisher;

  const ValidateReleaseMerge({
    Logger logger = const ConsoleLogger(),
    TagExists tagExists = const TagExists(),
    GetTagFormat gitTagFormat = const GetTagFormat(ResolveGitTagFormat()),
    DetectChangesInFolder detectChangesInFolder = const DetectChangesInFolder(),
    FindReleaseCandidatePackages findReleaseCandidatePackages =
        const FindReleaseCandidatePackages(),
    VerifyReleaseCompleteness verifyReleaseCompleteness =
        const VerifyReleaseCompleteness(),
    BuildStandardReleaseChecksBuilder standardReleaseChecksBuilder =
        const BuildStandardReleaseChecksBuilder(),
    PackagePublisher publisher = const PubPublish(),
  })  : _logger = logger,
        _detectChangesInFolder = detectChangesInFolder,
        _findReleaseCandidates = findReleaseCandidatePackages,
        _verifyReleaseCompleteness = verifyReleaseCompleteness,
        _tagExists = tagExists,
        _gitTagFormat = gitTagFormat,
        _standardReleaseChecksBuilder = standardReleaseChecksBuilder,
        _publisher = publisher;

  /// Runs the MR gate.
  ///
  /// Params:
  /// - `repoRoot`: absolute path to the repository root.
  /// - `fromBranch`: the MR's source branch, i.e. what is being merged
  ///   (e.g. `release/1.0.0`, or `HEAD` when that branch is checked out).
  /// - `toBranch`: the MR's target branch, i.e. what it merges into
  ///   (e.g. `origin/main`, `origin/release`).
  ///
  /// Returns: nothing (void) when every candidate is complete.
  ///
  /// Throws:
  /// - [GitDiffingException] when `git diff` fails.
  /// - [PackageFinderException] or [PackageRegistryLookupException] while
  ///   finding candidates (see [FindReleaseCandidatePackages]).
  /// - [TagLookupException] when a tag lookup fails for a reason other than
  ///   the tag not existing (see [TagExists]).
  /// - `PackageIdentityException` while checking a candidate's completeness
  ///   (see [VerifyReleaseCompleteness]).
  /// - [CommandNotFoundException] when neither fvm nor a system-wide
  ///   Dart/Flutter is installed for a candidate's dry-run publish check.
  /// - [ReleaseValidationException] listing every candidate with issues
  ///   (including a failed `dart pub publish --dry-run`), once all
  ///   candidates have been checked, so the MR gate fails.
  ///
  /// Notes: runs every check for every candidate rather than stopping at
  /// the first failure.
  Future<void> call({
    required String repoRoot,
    required String fromBranch,
    required String toBranch,
  }) async {
    _logger.info('Validating release merge...');

    // Diffs against the merge base of toBranch/fromBranch (git's `...`
    // syntax), so this yields exactly the changes fromBranch introduces on
    // top of toBranch — baseRef is the target, compareRef is the source.
    final changedFiles = await _detectChangesInFolder(
      baseRef: toBranch,
      compareRef: fromBranch,
    );

    final candidates = await _findReleaseCandidates(
      repoRoot: repoRoot,
      changedFiles: changedFiles,
    );
    if (candidates.isEmpty) {
      _logger.info('No release candidates found; nothing to validate.');
      return;
    }

    final checks = _standardReleaseChecksBuilder.build(_gitTagFormat);
    final validPackages = <String>{};
    final issuesMap = <String, List<String>>{};
    for (final candidate in candidates) {
      final issues = await _checkCandidate(candidate, repoRoot, checks);
      if (issues.isEmpty) {
        validPackages.add(candidate.packageIdentity.name);
      } else {
        issuesMap[candidate.packageIdentity.name] = issues;
      }
    }

    _logger.info(
      'Found ${candidates.length} release candidate(s):\n'
      '${_buildSummary(validPackages, issuesMap)}',
    );

    if (issuesMap.isNotEmpty) {
      throw ReleaseValidationException(
        '${issuesMap.length} release candidate(s) are incomplete.',
      );
    }
  }

  /// Checks a single candidate's tag availability, release completeness,
  /// and whether it would actually pass `dart pub publish --dry-run` — so
  /// pub-level rejections surface here, before the merge, rather than only
  /// once the post-merge publish step attempts them for real.
  ///
  /// Returns: issue messages describing what's wrong (empty when the
  /// candidate is valid).
  Future<List<String>> _checkCandidate(
    ReleaseCandidatePackage candidate,
    String repoRoot,
    Map<String, VersionedFileCheck> checks,
  ) async {
    final packagePath = p.join(repoRoot, candidate.repoRootRelativePath);
    final identity = candidate.packageIdentity;
    final tag = _gitTagFormat(name: identity.name, version: identity.version);
    final tagAlreadyExists = await _tagExists(tag, repoRoot: repoRoot);
    final completenessIssues = await _verifyReleaseCompleteness(
      packagePath,
      publishedPackageInfo: candidate.publishedPackageInfo,
      checks: checks,
    );
    final dryRunIssue = await _checkDryRunPublish(candidate, repoRoot);
    return [
      if (tagAlreadyExists) 'Tag $tag already exists.',
      ...completenessIssues.map((i) => i.issueMessage),
      if (dryRunIssue != null) dryRunIssue,
    ];
  }

  /// Returns: an issue message when a dry-run publish of [candidate]
  /// fails, otherwise null.
  Future<String?> _checkDryRunPublish(
    ReleaseCandidatePackage candidate,
    String repoRoot,
  ) async {
    try {
      await _publisher(
        repoRoot: repoRoot,
        pkgPath: candidate.repoRootRelativePath,
        identity: candidate.packageIdentity,
        dryRun: true,
        verbose: false,
      );
      return null;
    } on PublishFailedException catch (e) {
      return e.message;
    }
  }

  String _buildSummary(
    Set<String> validPackages,
    Map<String, List<String>> issuesMap,
  ) {
    final tick = stdout.supportsAnsiEscapes ? _greenTick : '✓';
    final cross = stdout.supportsAnsiEscapes ? _redCross : '✗';
    return [
      for (final name in validPackages) '  $tick $name: OK',
      for (final entry in issuesMap.entries) ...[
        '  $cross ${entry.key}:',
        for (final issue in entry.value) '      - $issue',
      ],
    ].join('\n');
  }
}
