import 'dart:io';

import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/use_cases/publish/build_publish_command.dart';
import 'package:dev_tools/src/use_cases/publish/publish_failed_exception.dart';
import 'package:dev_tools/src/utils/buffer_sink.dart';
import 'package:dev_tools/src/utils/interactive_process_runner.dart';
import 'package:dev_tools/src/utils/logger.dart';

/// Publishes (or dry-run validates) a package — to pub.dev via `dart pub
/// publish`, or a different registry/mechanism entirely.
abstract class PackagePublisher {
  /// Params:
  /// - `repoRoot`: absolute path to the repository root.
  /// - `pkgPath`: package directory relative to `repoRoot`.
  /// - `identity`: the package's name/version being published.
  /// - `dryRun`: validate only, without actually publishing.
  /// - `verbose`: when false, the publisher's own console output is
  ///   captured and only surfaced if it fails.
  ///
  /// Returns: nothing (void).
  ///
  /// Throws:
  /// - [PublishFailedException] when the publish (or dry run) fails.
  Future<void> call({
    required String repoRoot,
    required String pkgPath,
    required PackageIdentity identity,
    required bool dryRun,
    bool verbose = true,
  });
}

/// The default [PackagePublisher]: publishes via `dart pub publish` (or the
/// fvm-scoped equivalent) — i.e. to pub.dev, or wherever `PUB_HOSTED_URL`
/// points.
///
/// Notes: an actual (non-dry-run) publish passes `--force`, skipping pub's
/// own "are you sure?" confirmation — the caller is expected to have
/// already gated that decision itself, since a non-interactive (CI) run
/// would otherwise hang forever waiting for input that never comes.
class PubPublish implements PackagePublisher {
  final Logger _logger;
  final BuildPublishCommand _buildPublishCommand;

  const PubPublish({
    Logger logger = const ConsoleLogger(),
    BuildPublishCommand buildPublishCommand = const BuildPublishCommand(),
  })  : _logger = logger,
        _buildPublishCommand = buildPublishCommand;

  @override
  Future<void> call({
    required String repoRoot,
    required String pkgPath,
    required PackageIdentity identity,
    required bool dryRun,
    bool verbose = true,
  }) async {
    final tooling = await _buildPublishCommand(identity);
    final workingDirectory = '$repoRoot/$pkgPath';
    _logger.info(
      'Running ${dryRun ? 'dry-run ' : ''}publish for '
      '${identity.name} in $workingDirectory',
    );
    final exitCode = verbose
        ? await _runPubPublish(
            repoRoot,
            pkgPath,
            tooling: tooling,
            dryRun: dryRun,
          )
        : await _runSilently(
            repoRoot,
            pkgPath,
            tooling: tooling,
            dryRun: dryRun,
          );
    if (exitCode != 0) {
      throw PublishFailedException(
        dryRun
            ? 'Error: Dry-run failed. Fix issues before publishing.'
            : 'Error: Publishing failed.',
      );
    }
  }

  /// Same as running verbosely, but captures `dart pub publish`'s own
  /// console output instead of letting it print — surfaced only if the
  /// process actually fails, so a quiet run stays quiet on success.
  Future<int> _runSilently(
    String repoRoot,
    String pkgPath, {
    required PublishTooling tooling,
    required bool dryRun,
  }) async {
    final out = BufferSink();
    final err = BufferSink();
    final exitCode = await _runPubPublish(
      repoRoot,
      pkgPath,
      tooling: tooling,
      dryRun: dryRun,
      stdOut: out,
      stdErr: err,
    );
    if (exitCode != 0) {
      _logger
        ..info(out.contents)
        ..warn(err.contents);
    }
    return exitCode;
  }

  static Future<int> _runPubPublish(
    String repoRoot,
    String pkgPath, {
    required PublishTooling tooling,
    required bool dryRun,
    IOSink? stdOut,
    IOSink? stdErr,
  }) {
    final args = [
      ...tooling.prefix,
      'pub',
      'publish',
      if (dryRun) '--dry-run',
      if (!dryRun) '--force',
    ];
    final runner = InteractiveProcessRunner(
      executable: args.first,
      arguments: args.sublist(1),
      workingDirectory: '$repoRoot/$pkgPath',
      stdOut: stdOut,
      stdErr: stdErr,
    );
    return runner.run();
  }
}
