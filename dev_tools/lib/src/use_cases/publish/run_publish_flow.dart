import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/read_package_identity.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/validate_package_path.dart';
import 'package:dev_tools/src/use_cases/git/get_tag_format.dart';
import 'package:dev_tools/src/use_cases/git/has_clean_working_tree.dart';
import 'package:dev_tools/src/use_cases/prompts/confirm_yes_no.dart';
import 'package:dev_tools/src/use_cases/publish/build_publish_command.dart';
import 'package:dev_tools/src/use_cases/publish/package_publisher.dart';
import 'package:dev_tools/src/use_cases/publish/publish_failed_exception.dart';
import 'package:dev_tools/src/use_cases/publish/publish_validation_exception.dart';
import 'package:dev_tools/src/use_cases/release/fetch_pub_dev_package_info.dart';
import 'package:dev_tools/src/use_cases/release/package_registry_client.dart';
import 'package:dev_tools/src/use_cases/release/release_validation_exception.dart';
import 'package:dev_tools/src/use_cases/release/standard_release_checks_builder.dart';
import 'package:dev_tools/src/use_cases/release/verify_release_completeness.dart';
import 'package:dev_tools/src/utils/logger.dart';
import 'package:path/path.dart' as p;

class RunPublishFlow {
  final Logger _logger;
  final ConfirmYesNo _confirmYesNo;
  final HasCleanWorkingTree _hasCleanWorkingTree;
  final ValidatePackagePath _validatePackagePath;
  final ReadPackageIdentity _readPackageIdentity;
  final BuildPublishCommand _buildPublishCommand;
  final VerifyReleaseCompleteness _verifyReleaseCompleteness;
  final PackageRegistryClient _packageRegistryClient;
  final GetTagFormat _gitTagFormat;
  final BuildStandardReleaseChecksBuilder _buildStandardReleaseChecks;
  final PackagePublisher _publisher;

  const RunPublishFlow({
    Logger logger = const ConsoleLogger(),
    ConfirmYesNo confirmYesNo = const ConfirmYesNo(),
    HasCleanWorkingTree hasCleanWorkingTree = const HasCleanWorkingTree(),
    ValidatePackagePath validatePackagePath = const ValidatePackagePath(),
    ReadPackageIdentity readPackageIdentity = const ReadPackageIdentity(),
    BuildPublishCommand buildPublishCommand = const BuildPublishCommand(),
    VerifyReleaseCompleteness verifyReleaseCompleteness =
        const VerifyReleaseCompleteness(),
    PackageRegistryClient packageRegistryClient =
        const FetchPubDevPackageInfo(),
    GetTagFormat gitTagFormat = const GetTagFormat(ResolveGitTagFormat()),
    BuildStandardReleaseChecksBuilder buildStandardReleaseChecks =
        const BuildStandardReleaseChecksBuilder(),
    PackagePublisher publisher = const PubPublish(),
  })  : _logger = logger,
        _confirmYesNo = confirmYesNo,
        _hasCleanWorkingTree = hasCleanWorkingTree,
        _validatePackagePath = validatePackagePath,
        _readPackageIdentity = readPackageIdentity,
        _buildPublishCommand = buildPublishCommand,
        _verifyReleaseCompleteness = verifyReleaseCompleteness,
        _packageRegistryClient = packageRegistryClient,
        _gitTagFormat = gitTagFormat,
        _buildStandardReleaseChecks = buildStandardReleaseChecks,
        _publisher = publisher;

  /// Validates and publishes a package.
  ///
  /// Params:
  /// - `repoRoot`: absolute path to the repository root.
  /// - `pkgPath`: package directory relative to [repoRoot].
  /// - `dryRunOnly`: run only a dry-run publish, skipping the actual
  ///   publish; when false, publishes directly without a preceding dry run.
  /// - `interactive`: when false, skip both confirmation prompts (warnings
  ///   are still logged, just not gated on); for unattended/CI callers that
  ///   have already decided this candidate should be published.
  /// - `verbose`: when false, suppress all progress output (package/version,
  ///   warnings, dry-run/publish progress) — including `dart pub publish`'s
  ///   own console output, captured and only printed if it actually fails;
  ///   for batch callers that only want to know about failures, reporting
  ///   their own progress (or none) at a coarser level.
  ///
  /// Returns: nothing (void).
  ///
  /// Throws:
  /// - [PublishValidationException] on an invalid package path.
  /// - [PackageIdentityException] when the pubspec is missing or lacks a
  ///   `name` or `version` (see [ReadPackageIdentity]).
  /// - [CommandNotFoundException] when neither fvm nor a system-wide
  ///   Dart/Flutter is installed (see [BuildPublishCommand]).
  /// - [PackageRegistryLookupException] when the package registry cannot
  ///   be reached.
  /// - [ReleaseValidationException] on incomplete release references (see
  ///   [VerifyReleaseCompleteness]).
  /// - [PublishFailedException] when the dry run or publish fails.
  ///
  /// Notes: the dry run and publish go through the injected
  /// [PackagePublisher], which resolves its own [PublishTooling] from the
  /// package identity; without a scoped fvm version the user is warned
  /// that the system-wide Dart/Flutter will be used. When
  /// `interactive` is true (the default), warnings (system-wide toolchain,
  /// uncommitted changes) are confirmed with a single `Continue despite
  /// warnings?` prompt, and the actual publish requires a final
  /// confirmation. When `verbose`, reports one line per step (package,
  /// warnings if any, dry-run, publish) — no empty sections, no shouting.
  Future<void> call({
    required String repoRoot,
    required String pkgPath,
    bool dryRunOnly = true,
    bool interactive = true,
    bool verbose = true,
  }) async {
    final packagePath = p.join(repoRoot, pkgPath);
    _validatePackagePath(packagePath);

    final identity = await _readPackageIdentity(packagePath);
    final tooling = await _buildPublishCommand(identity);
    final label = '${identity.name}@${identity.version}';

    _log('Publishing $label ...', verbose: verbose);
    await _ensureReleaseIsComplete(packagePath, identity);

    final warnings = await _collectWarnings(repoRoot, tooling);
    _logWarnings(warnings, verbose);
    if (warnings.isNotEmpty &&
        await _declinedConfirmation(
          'Continue despite warnings?',
          interactive: interactive,
          verbose: verbose,
        )) {
      return;
    }

    if (dryRunOnly) {
      await _publisher(
        repoRoot: repoRoot,
        pkgPath: pkgPath,
        identity: identity,
        dryRun: true,
        verbose: verbose,
      );
      _log('  Dry-run publish passed.', verbose: verbose);
      return;
    }

    if (await _declinedConfirmation(
      'Publish $label?',
      interactive: interactive,
      verbose: verbose,
    )) {
      return;
    }

    await _publisher(
      repoRoot: repoRoot,
      pkgPath: pkgPath,
      identity: identity,
      dryRun: false,
      verbose: verbose,
    );
    _log('  Published.', verbose: verbose);
  }

  void _log(String message, {required bool verbose}) {
    if (verbose) _logger.info(message);
  }

  void _logWarnings(List<String> warnings, bool verbose) {
    _log('  Warning:', verbose: verbose);
    for (final warning in warnings) {
      _log('  - $warning', verbose: verbose);
    }
  }

  /// Throws [ReleaseValidationException] when [identity]'s release has
  /// incomplete CHANGELOG/README references (see
  /// [BuildStandardReleaseChecksBuilder]).
  Future<void> _ensureReleaseIsComplete(
    String packagePath,
    PackageIdentity identity,
  ) async {
    final publishedPackageInfo = await _packageRegistryClient(identity.name);
    final releaseIssues = await _verifyReleaseCompleteness(
      packagePath,
      publishedPackageInfo: publishedPackageInfo,
      checks: _buildStandardReleaseChecks.build(_gitTagFormat),
    );
    if (releaseIssues.isNotEmpty) {
      throw ReleaseValidationException(
        releaseIssues.map((i) => i.issueMessage).join('\n'),
      );
    }
  }

  /// Non-fatal issues about this publish worth flagging before it proceeds
  /// (missing fvm scoping, uncommitted changes).
  Future<List<String>> _collectWarnings(
    String repoRoot,
    PublishTooling tooling,
  ) async {
    final warnings = <String>[];
    if (!tooling.usesFvm) {
      warnings
          .add('Project not scoped with fvm, using system-wide Dart/Flutter.');
    }
    if (!await _hasCleanWorkingTree(repoRoot)) {
      warnings.add('You have uncommitted changes.');
    }
    return warnings;
  }

  /// Asks [question] when [interactive], logging `  Cancelled.` (subject to
  /// [verbose]) and returning true when the answer is no. Returns false
  /// without asking when not interactive.
  Future<bool> _declinedConfirmation(
    String question, {
    required bool interactive,
    required bool verbose,
  }) async {
    if (!interactive || await _confirmYesNo(question)) {
      return false;
    }
    _log('  Cancelled.', verbose: verbose);
    return true;
  }
}
