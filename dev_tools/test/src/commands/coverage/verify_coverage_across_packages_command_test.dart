import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/coverage/verify_coverage_across_packages_command.dart';
import 'package:dev_tools/src/use_cases/coverage/verify_coverage_across_packages.dart';
import 'package:dev_tools/src/use_cases/git/get_repo_root_path.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockGetRepoRootPath extends Mock implements GetRepoRootPath {}

class _MockVerifyCoverageAcrossPackages extends Mock
    implements VerifyCoverageAcrossPackages {}

void main() {
  late _MockGetRepoRootPath getRepoRootPath;
  late _MockVerifyCoverageAcrossPackages verifyCoverageAcrossPackages;
  late VerifyCoverageAcrossPackagesCommand sut;

  setUp(() {
    getRepoRootPath = _MockGetRepoRootPath();
    when(() => getRepoRootPath()).thenAnswer((_) async => '/fake/repo');

    verifyCoverageAcrossPackages = _MockVerifyCoverageAcrossPackages();
    when(() => verifyCoverageAcrossPackages(
          repoRoot: any(named: 'repoRoot'),
          packagePaths: any(named: 'packagePaths'),
          globalThreshold: any(named: 'globalThreshold'),
        )).thenAnswer((_) async {});

    sut = VerifyCoverageAcrossPackagesCommand(
      getRepoRootPath: getRepoRootPath,
      verifyCoverageAcrossPackages: verifyCoverageAcrossPackages,
    );
  });

  test('should expose the verify name', () {
    expect(sut.name, VerifyCoverageAcrossPackagesCommand.commandName);
  });

  test('should describe running given packages with coverage', () {
    expect(sut.description,
        VerifyCoverageAcrossPackagesCommand.commandDescription);
  });

  test('should throw a usage exception when no package is given', () async {
    await expectLater(_run(<String>[], sut), throwsA(isA<UsageException>()));

    verifyNever(() => verifyCoverageAcrossPackages(
          repoRoot: any(named: 'repoRoot'),
          packagePaths: any(named: 'packagePaths'),
          globalThreshold: any(named: 'globalThreshold'),
        ));
  });

  test('should use the resolved repo root and default threshold', () async {
    await _run(['--package=pkg_a'], sut);

    verify(
      () => verifyCoverageAcrossPackages(
        repoRoot: '/fake/repo',
        packagePaths: ['pkg_a'],
        // ignore: avoid_redundant_argument_values
        globalThreshold: 100,
      ),
    ).called(1);
  });

  test('should forward every supplied package and a custom threshold',
      () async {
    await _run(
      ['--package=pkg_a', '--package=pkg_b', '--threshold=90'],
      sut,
    );

    verify(
      () => verifyCoverageAcrossPackages(
        repoRoot: '/fake/repo',
        packagePaths: ['pkg_a', 'pkg_b'],
        globalThreshold: 90,
      ),
    ).called(1);
  });
}

Future<void> _run(
  List<String> args,
  VerifyCoverageAcrossPackagesCommand command,
) async {
  final runner = CommandRunner<void>('dev_tools', '')..addCommand(command);
  await runner.run(['verify', ...args]);
}
