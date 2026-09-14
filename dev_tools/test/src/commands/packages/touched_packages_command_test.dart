import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/packages/touched_packages_command.dart';
import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/models/package_info.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_touched_packages.dart';
import 'package:dev_tools/src/use_cases/git/get_repo_root_path.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockGetRepoRootPath extends Mock implements GetRepoRootPath {}

class _MockFindTouchedPackages extends Mock implements FindTouchedPackages {}

class _MockIOSink extends Mock implements IOSink {}

void main() {
  late _MockIOSink out;
  late _MockGetRepoRootPath getRepoRootPath;
  late _MockFindTouchedPackages findTouchedPackages;
  late TouchedPackagesCommand sut;

  setUp(() {
    out = _MockIOSink();

    getRepoRootPath = _MockGetRepoRootPath();
    when(() => getRepoRootPath()).thenAnswer((_) async => '/fake/repo');

    findTouchedPackages = _MockFindTouchedPackages();
    when(() => findTouchedPackages(
          repoRoot: any(named: 'repoRoot'),
          fromRef: any(named: 'fromRef'),
          toRef: any(named: 'toRef'),
          skipPaths: any(named: 'skipPaths'),
        )).thenAnswer((_) async => const <ValidLocalPackageInfo>[]);

    sut = TouchedPackagesCommand(
      out: out,
      getRepoRootPath: getRepoRootPath,
      findTouchedPackages: findTouchedPackages,
    );
  });

  test('should expose the get-touched name', () {
    expect(sut.name, TouchedPackagesCommand.commandName);
  });

  test('should describe printing touched packages', () {
    expect(sut.description, TouchedPackagesCommand.commandDescription);
  });

  test('should use the resolved repo root and default from/to', () async {
    await _run(<String>[], sut);

    verify(
      () => findTouchedPackages(
        repoRoot: '/fake/repo',
        // ignore: avoid_redundant_argument_values
        fromRef: 'HEAD^',
        // ignore: avoid_redundant_argument_values
        toRef: 'HEAD',
        // ignore: avoid_redundant_argument_values
        skipPaths: const [],
      ),
    ).called(1);
  });

  test('should forward a supplied from, to, and skip paths', () async {
    await _run(
      [
        '--from=main~5',
        '--to=main',
        '--skip-path=app_template',
        '--skip-path=demo',
      ],
      sut,
    );

    verify(
      () => findTouchedPackages(
        repoRoot: '/fake/repo',
        fromRef: 'main~5',
        toRef: 'main',
        skipPaths: ['app_template', 'demo'],
      ),
    ).called(1);
  });

  test('should complete without error when no package was touched', () async {
    await expectLater(_run(<String>[], sut), completes);
  });

  test('should print each touched package to stdout', () async {
    when(() => findTouchedPackages(
          repoRoot: any(named: 'repoRoot'),
          fromRef: any(named: 'fromRef'),
          toRef: any(named: 'toRef'),
          skipPaths: any(named: 'skipPaths'),
        )).thenAnswer((_) async => [
          const ValidLocalPackageInfo(
            repoRootRelativePath: 'pkg_a',
            packageIdentity: PackageIdentity(
              name: 'pkg_a',
              version: '1.0.0',
            ),
          ),
        ]);

    await _run(<String>[], sut);

    verify(() => out.writeln('pkg_a')).called(1);
  });
}

Future<void> _run(
  List<String> args,
  TouchedPackagesCommand command,
) async {
  final runner = CommandRunner<void>('dev_tools', '')..addCommand(command);
  await runner.run(['get-touched', ...args]);
}
