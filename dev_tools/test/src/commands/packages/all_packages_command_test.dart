import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/packages/all_packages_command.dart';
import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/models/package_info.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_all_packages.dart';
import 'package:dev_tools/src/use_cases/git/get_repo_root_path.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockGetRepoRootPath extends Mock implements GetRepoRootPath {}

class _MockFindAllPackages extends Mock implements FindAllPackages {}

void main() {
  late _MockGetRepoRootPath getRepoRootPath;
  late _MockFindAllPackages findAllPackages;
  late AllPackagesCommand sut;

  setUp(() {
    getRepoRootPath = _MockGetRepoRootPath();
    when(() => getRepoRootPath()).thenAnswer((_) async => '/fake/repo');

    findAllPackages = _MockFindAllPackages();
    when(() => findAllPackages(
          repoRoot: any(named: 'repoRoot'),
          skipPaths: any(named: 'skipPaths'),
        )).thenAnswer((_) async => const <ValidLocalPackageInfo>[]);

    sut = AllPackagesCommand(
      getRepoRootPath: getRepoRootPath,
      findAllPackages: findAllPackages,
    );
  });

  test('should expose the get-all name', () {
    expect(sut.name, AllPackagesCommand.commandName);
  });

  test('should describe printing every package', () {
    expect(sut.description, AllPackagesCommand.commandDescription);
  });

  test('should use the resolved repo root and no skip paths by default',
      () async {
    await _run(<String>[], sut);

    verify(
      () => findAllPackages(
        repoRoot: '/fake/repo',
        // ignore: avoid_redundant_argument_values
        skipPaths: const [],
      ),
    ).called(1);
  });

  test('should forward supplied skip paths', () async {
    await _run(['--skip-path=app_template', '--skip-path=demo'], sut);

    verify(
      () => findAllPackages(
        repoRoot: '/fake/repo',
        skipPaths: ['app_template', 'demo'],
      ),
    ).called(1);
  });

  test('should complete without error when no packages are found', () async {
    await expectLater(_run(<String>[], sut), completes);
  });

  test('should complete without error when packages are found', () async {
    when(() => findAllPackages(
          repoRoot: any(named: 'repoRoot'),
          skipPaths: any(named: 'skipPaths'),
        )).thenAnswer((_) async => const [
          ValidLocalPackageInfo(
            repoRootRelativePath: 'pkg_a',
            packageIdentity: PackageIdentity(name: 'pkg_a', version: '1.0.0'),
          ),
        ]);

    await expectLater(_run(<String>[], sut), completes);
  });
}

Future<void> _run(
  List<String> args,
  AllPackagesCommand command,
) async {
  final runner = CommandRunner<void>('dev_tools', '')..addCommand(command);
  await runner.run(['get-all', ...args]);
}
