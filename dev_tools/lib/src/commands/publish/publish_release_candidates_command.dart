// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/git/get_repo_root_path.dart';
import 'package:dev_tools/src/use_cases/git/get_tag_format.dart';
import 'package:dev_tools/src/use_cases/publish/publish_release_candidates.dart';

class PublishReleaseCandidatesCommand extends Command<void> {
  static const String commandName = 'publish-release-candidates';
  static const String commandDescription =
      'Publish and tag every eligible release candidate among a given set of packages.'
      '\n\nNotes:\n'
      '- Tag style defaults to "${ResolveGitTagFormat.defaultGitTagFormat}".\n'
      '  To customize, override the ${ResolveGitTagFormat.gitTagFormatEnvVar} env var.\n'
      '  Supported placeholders are "{name}" & "{version}".'
      '  For example, a custom override might be "{name}@{version}".';

  static const String packageOption = 'package';
  static const String dryRunFlag = 'dry-run';

  final GetRepoRootPath _getRepoRootPath;
  final PublishReleaseCandidates _publishReleaseCandidates;

  PublishReleaseCandidatesCommand({
    GetRepoRootPath getRepoRootPath = const GetRepoRootPath(),
    PublishReleaseCandidates publishReleaseCandidates =
        const PublishReleaseCandidates(),
  })  : _getRepoRootPath = getRepoRootPath,
        _publishReleaseCandidates = publishReleaseCandidates {
    argParser
      ..addMultiOption(
        packageOption,
        abbr: 'p',
        help: 'Repo-root-relative path of a package to consider '
            '(e.g. packages/foo). Repeatable; at least one is required.',
      )
      ..addFlag(
        dryRunFlag,
        negatable: false,
        help: "Run each candidate's dry-run publish only; publish nothing "
            'and create no tags.',
      );
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void>? run() async {
    final packagePaths = argResults![packageOption] as List<String>;
    if (packagePaths.isEmpty) {
      usageException('At least one --$packageOption must be provided.');
    }

    final repoRoot = await _getRepoRootPath();
    await _publishReleaseCandidates(
      repoRoot: repoRoot,
      packagePaths: packagePaths,
      dryRun: argResults!.flag(dryRunFlag),
    );
  }
}
