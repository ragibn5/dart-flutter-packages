// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/coverage/verify_coverage_across_packages.dart';
import 'package:dev_tools/src/use_cases/git/get_repo_root_path.dart';

class VerifyCoverageAcrossPackagesCommand extends Command<void> {
  static const String commandName = 'verify';
  static const String commandDescription =
      "Run every given package's tests with coverage and enforce a minimum line-coverage threshold (default 100%) on each."
      '\n\nNotes:\n'
      '- A package may contain a `dev_tools_coverage_config.yaml` file, which may contain:\n'
      '    - `threshold`: its own threshold (overwrites the `--$thresholdOption` option)\n'
      '    - `exclude`: glob exclude patterns (relative to package root, not repo root)';

  static const String packageOption = 'package';
  static const String thresholdOption = 'threshold';

  final GetRepoRootPath _getRepoRootPath;
  final VerifyCoverageAcrossPackages _verifyCoverageAcrossPackages;

  VerifyCoverageAcrossPackagesCommand({
    GetRepoRootPath getRepoRootPath = const GetRepoRootPath(),
    VerifyCoverageAcrossPackages verifyCoverageAcrossPackages =
        const VerifyCoverageAcrossPackages(),
  })  : _getRepoRootPath = getRepoRootPath,
        _verifyCoverageAcrossPackages = verifyCoverageAcrossPackages {
    argParser
      ..addMultiOption(
        packageOption,
        abbr: 'p',
        help: 'Repo-root-relative path of a package to check '
            '(e.g. packages/foo). Repeatable; at least one is required.',
      )
      ..addOption(
        thresholdOption,
        defaultsTo: '100',
        help: 'Global coverage percentage.',
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
    final threshold =
        double.tryParse(argResults![thresholdOption] as String) ?? 100.0;
    await _verifyCoverageAcrossPackages(
      repoRoot: repoRoot,
      packagePaths: packagePaths,
      globalThreshold: threshold,
    );
  }
}
