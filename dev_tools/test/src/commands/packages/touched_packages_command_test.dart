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

void main() {
  late _MockGetRepoRootPath getRepoRootPath;
  late _MockFindTouchedPackages findTouchedPackages;
  late TouchedPackagesCommand sut;

  setUp(() {
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

  test('should complete without error when packages were touched', () async {
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

    await expectLater(_run(<String>[], sut), completes);
  });
}

Future<void> _run(
  List<String> args,
  TouchedPackagesCommand command,
) async {
  final runner = CommandRunner<void>('dev_tools', '')..addCommand(command);
  await runner.run(['get-touched', ...args]);
}
