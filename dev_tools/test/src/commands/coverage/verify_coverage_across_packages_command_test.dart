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
          fromRef: any(named: 'fromRef'),
          toRef: any(named: 'toRef'),
          globalThreshold: any(named: 'globalThreshold'),
          skipPaths: any(named: 'skipPaths'),
          all: any(named: 'all'),
        )).thenAnswer((_) async {});

    sut = VerifyCoverageAcrossPackagesCommand(
      getRepoRootPath: getRepoRootPath,
      verifyCoverageAcrossPackages: verifyCoverageAcrossPackages,
    );
  });

  test('should expose the verify-packages name', () {
    expect(sut.name, VerifyCoverageAcrossPackagesCommand.commandName);
  });

  test('should describe enforcing coverage across every package', () {
    expect(sut.description,
        VerifyCoverageAcrossPackagesCommand.commandDescription);
  });

  test('should use the resolved repo root and default from/to/threshold',
      () async {
    await _run(<String>[], sut);

    verify(
      () => verifyCoverageAcrossPackages(
        repoRoot: '/fake/repo',
        // ignore: avoid_redundant_argument_values
        fromRef: 'HEAD^',
        // ignore: avoid_redundant_argument_values
        toRef: 'HEAD',
        // ignore: avoid_redundant_argument_values
        globalThreshold: 100,
        // ignore: avoid_redundant_argument_values
        skipPaths: const [],
        // ignore: avoid_redundant_argument_values
        all: false,
      ),
    ).called(1);
  });

  test('should forward a supplied from, to, threshold, and skip paths',
      () async {
    await _run(
      [
        '--from=main~5',
        '--to=main',
        '--threshold=90',
        '--skip-path=app_template',
        '--skip-path=demo',
      ],
      sut,
    );

    verify(
      () => verifyCoverageAcrossPackages(
        repoRoot: '/fake/repo',
        fromRef: 'main~5',
        toRef: 'main',
        globalThreshold: 90,
        skipPaths: ['app_template', 'demo'],
        // ignore: avoid_redundant_argument_values
        all: false,
      ),
    ).called(1);
  });

  test('should forward the all flag when supplied', () async {
    await _run(['--all'], sut);

    verify(
      () => verifyCoverageAcrossPackages(
        repoRoot: '/fake/repo',
        // ignore: avoid_redundant_argument_values
        fromRef: 'HEAD^',
        // ignore: avoid_redundant_argument_values
        toRef: 'HEAD',
        // ignore: avoid_redundant_argument_values
        globalThreshold: 100,
        // ignore: avoid_redundant_argument_values
        skipPaths: const [],
        all: true,
      ),
    ).called(1);
  });
}

Future<void> _run(
  List<String> args,
  VerifyCoverageAcrossPackagesCommand command,
) async {
  final runner = CommandRunner<void>('dev_tools', '')..addCommand(command);
  await runner.run(['verify-packages', ...args]);
}
