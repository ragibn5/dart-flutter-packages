import 'dart:io';

import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/models/package_info.dart';
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

/// Result of scanning the repo for packages, split by validity.
typedef _PackageScanResult = ({
  List<ValidLocalPackageInfo> valid,
  List<MalformedLocalPackageInfo> malformed,
});

/// Result of checking every release candidate: names that passed, and the
/// issues found for every one that didn't.
// ignore: avoid_private_typedef_functions
typedef _ReleaseCheckResult = ({
  Set<String> validNames,
  Map<String, List<String>> issuesByName,
});

/// Orchestrates the MR-to-target-branch release gate end to end.
class ValidateReleaseMerge {
  final Logger _logger;
  final TagExists _tagExists;
  final GetTagFormat _gitTagFormat;
  final DetectChangesInFolder _detectChangesInFolder;
  final FindPackages _findPackages;
  final FindReleaseCandidatePackages _findReleaseCandidates;
  final VerifyReleaseCompleteness _verifyReleaseCompleteness;
  final BuildStandardReleaseChecksBuilder _standardReleaseChecksBuilder;
  final PackagePublisher _publisher;

  const ValidateReleaseMerge({
    Logger logger = const ConsoleLogger(),
    TagExists tagExists = const TagExists(),
    GetTagFormat gitTagFormat = const GetTagFormat(ResolveGitTagFormat()),
    DetectChangesInFolder detectChangesInFolder = const DetectChangesInFolder(),
    FindPackages findPackages = const FindPackages(),
    FindReleaseCandidatePackages findReleaseCandidatePackages =
        const FindReleaseCandidatePackages(),
    VerifyReleaseCompleteness verifyReleaseCompleteness =
        const VerifyReleaseCompleteness(),
    BuildStandardReleaseChecksBuilder standardReleaseChecksBuilder =
        const BuildStandardReleaseChecksBuilder(),
    PackagePublisher publisher = const PubPublish(),
  })  : _logger = logger,
        _detectChangesInFolder = detectChangesInFolder,
        _findPackages = findPackages,
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
  /// - [PackageFinderException] while scanning for packages (see
  ///   [FindPackages]).
  /// - [PackageRegistryLookupException] while narrowing candidates (see
  ///   [FindReleaseCandidatePackages]).
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
  /// the first failure. In GitHub Actions (detected via the `GITHUB_ACTIONS`
  /// environment variable), each candidate's own check is wrapped in its
  /// own `::group::`/`::endgroup::` pair so the Actions log renders it as a
  /// collapsed, foldable section instead of one long unfolded dump. The
  /// candidate-count header, the malformed-package listing, and the final
  /// summary are always left unfolded, since those are what a reader
  /// actually wants visible at a glance.
  Future<void> call({
    required String repoRoot,
    required String fromBranch,
    required String toBranch,
  }) async {
    final packages = await _logger.withGroupedLog(
      'Scanning for packages...',
      (logger) => _extractPackages(repoRoot, logger),
    );
    final candidates = await _logger.withGroupedLog(
      'Filtering release candidates...',
      (logger) =>
          _extractReleaseCandidates(toBranch, fromBranch, packages, logger),
    );

    final results = await _validateReleaseCandidates(repoRoot, candidates);
    _logger.info(
      'Validation report for ${candidates.length} release candidate(s):\n'
      '${_buildSummary(results.validNames, results.issuesByName)}',
    );

    if (results.issuesByName.isNotEmpty) {
      throw ReleaseValidationException(
        '${results.issuesByName.length} release candidate(s) are incomplete.',
      );
    }
  }

  Future<List<ReleaseCandidatePackage>> _extractReleaseCandidates(
    String toBranch,
    String fromBranch,
    _PackageScanResult packages,
    Logger logger,
  ) async {
    final changedFiles = await _detectChangesInFolder(
      baseRef: toBranch,
      compareRef: fromBranch,
    );
    final candidates = await _findReleaseCandidates(
      localPackages: packages.valid,
      changedFiles: changedFiles,
    );

    if (candidates.isEmpty) {
      logger.info('No release candidates found; nothing to validate.');
    } else {
      logger.info('Found ${candidates.length} release candidate(s).');
    }

    return candidates;
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

  Future<_ReleaseCheckResult> _validateReleaseCandidates(
    String repoRoot,
    List<ReleaseCandidatePackage> candidates,
  ) async {
    final validPackageNames = <String>{};
    final issuesMap = <String, List<String>>{};
    final checks = _standardReleaseChecksBuilder.build(_gitTagFormat);
    for (var i = 0; i < candidates.length; ++i) {
      final candidate = candidates[i];
      final name = candidate.packageIdentity.name;
      final issues = await _logger.withGroupedLog(
        '[${i + 1}/${candidates.length})] Validating $name ...',
        (logger) => _checkCandidate(candidate, repoRoot, checks),
      );
      if (issues.isEmpty) {
        validPackageNames.add(name);
      } else {
        issuesMap[name] = issues;
      }
    }

    return (validNames: validPackageNames, issuesByName: issuesMap);
  }

  Future<List<String>> _checkCandidate(
    ReleaseCandidatePackage candidate,
    String repoRoot,
    Map<String, VersionedFileCheck> checks,
  ) async {
    final packagePath = p.join(repoRoot, candidate.repoRootRelativePath);

    final identity = candidate.packageIdentity;
    final tag = _gitTagFormat(name: identity.name, version: identity.version!);
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
