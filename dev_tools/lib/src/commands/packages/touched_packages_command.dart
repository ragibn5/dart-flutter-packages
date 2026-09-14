// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_touched_packages.dart';
import 'package:dev_tools/src/use_cases/git/get_repo_root_path.dart';

class TouchedPackagesCommand extends Command<void> {
  static const String commandName = 'touched';
  static const String commandDescription =
      'Print the repo-root-relative path of every package touched between two git refs, one per line.';

  static const String fromOption = 'from';
  static const String toOption = 'to';
  static const String skipPathOption = 'skip-path';

  final GetRepoRootPath _getRepoRootPath;
  final FindTouchedPackages _findTouchedPackages;

  TouchedPackagesCommand({
    GetRepoRootPath getRepoRootPath = const GetRepoRootPath(),
    FindTouchedPackages findTouchedPackages = const FindTouchedPackages(),
  })  : _getRepoRootPath = getRepoRootPath,
        _findTouchedPackages = findTouchedPackages {
    argParser
      ..addOption(
        fromOption,
        defaultsTo: 'HEAD^',
        help: 'The branch state before this change '
            '(default: the previous commit).',
      )
      ..addOption(
        toOption,
        defaultsTo: 'HEAD',
        help: 'The branch state after this change '
            '(default: the currently checked-out commit).',
      )
      ..addMultiOption(
        skipPathOption,
        abbr: 's',
        help: 'Repo-root-relative path prefix of a whole package to skip '
            'entirely (e.g. app_template).',
      );
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void>? run() async {
    final repoRoot = await _getRepoRootPath();
    final packages = await _findTouchedPackages(
      repoRoot: repoRoot,
      fromRef: argResults![fromOption] as String,
      toRef: argResults![toOption] as String,
      skipPaths: argResults![skipPathOption] as List<String>,
    );

    for (final package in packages) {
      print(package.repoRootRelativePath);
    }
  }
}
