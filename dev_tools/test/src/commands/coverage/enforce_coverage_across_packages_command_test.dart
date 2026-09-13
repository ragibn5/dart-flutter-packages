import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/coverage/enforce_coverage_across_packages_command.dart';
import 'package:dev_tools/src/use_cases/coverage/enforce_coverage_across_packages.dart';
import 'package:dev_tools/src/use_cases/git/get_repo_root_path.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockGetRepoRootPath extends Mock implements GetRepoRootPath {}

class _MockEnforceCoverageAcrossPackages extends Mock
    implements EnforceCoverageAcrossPackages {}

void main() {
  late _MockGetRepoRootPath getRepoRootPath;
  late _MockEnforceCoverageAcrossPackages enforceCoverageAcrossPackages;
  late EnforceCoverageAcrossPackagesCommand sut;

  setUp(() {
    getRepoRootPath = _MockGetRepoRootPath();
    when(() => getRepoRootPath()).thenAnswer((_) async => '/fake/repo');

    enforceCoverageAcrossPackages = _MockEnforceCoverageAcrossPackages();
    when(() => enforceCoverageAcrossPackages(
          repoRoot: any(named: 'repoRoot'),
          threshold: any(named: 'threshold'),
          exclude: any(named: 'exclude'),
        )).thenAnswer((_) async {});

    sut = EnforceCoverageAcrossPackagesCommand(
      getRepoRootPath: getRepoRootPath,
      enforceCoverageAcrossPackages: enforceCoverageAcrossPackages,
    );
  });

  test('should expose the coverage name', () {
    expect(sut.name, EnforceCoverageAcrossPackagesCommand.commandName);
  });

  test('should describe enforcing coverage across every package', () {
    expect(sut.description,
        EnforceCoverageAcrossPackagesCommand.commandDescription);
  });

  test('should use the resolved repo root and default threshold', () async {
    await _run(<String>[], sut);

    verify(
      () => enforceCoverageAcrossPackages(
        repoRoot: '/fake/repo',
        // ignore: avoid_redundant_argument_values
        threshold: 100,
        // ignore: avoid_redundant_argument_values
        exclude: const [],
      ),
    ).called(1);
  });

  test('should forward a supplied threshold and exclusions', () async {
    await _run(
      ['--threshold=90', '--exclude=app_template', '--exclude=demo'],
      sut,
    );

    verify(
      () => enforceCoverageAcrossPackages(
        repoRoot: '/fake/repo',
        threshold: 90,
        exclude: ['app_template', 'demo'],
      ),
    ).called(1);
  });
}

Future<void> _run(
  List<String> args,
  EnforceCoverageAcrossPackagesCommand command,
) async {
  final runner = CommandRunner<void>('dev_tools', '')..addCommand(command);
  await runner.run(['coverage', ...args]);
}
