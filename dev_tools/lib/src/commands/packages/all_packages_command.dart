// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_all_packages.dart';
import 'package:dev_tools/src/use_cases/git/get_repo_root_path.dart';

class AllPackagesCommand extends Command<void> {
  static const String commandName = 'get-all';

  static const String commandDescription =
      'Print the repo-root-relative path of every package in the repository, one per line.';

  static const String skipPathOption = 'skip-path';

  final IOSink _out;
  final GetRepoRootPath _getRepoRootPath;
  final FindAllPackages _findAllPackages;

  AllPackagesCommand({
    IOSink? out,
    GetRepoRootPath getRepoRootPath = const GetRepoRootPath(),
    FindAllPackages findAllPackages = const FindAllPackages(),
  })  : _out = out ?? stdout,
        _getRepoRootPath = getRepoRootPath,
        _findAllPackages = findAllPackages {
    argParser.addMultiOption(
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
    final packages = await _findAllPackages(
      repoRoot: repoRoot,
      skipPaths: argResults![skipPathOption] as List<String>,
    );

    if (packages.isEmpty) {
      return;
    }

    _out.writeln(packages.map((p) => p.repoRootRelativePath).join('\n'));
  }
}
