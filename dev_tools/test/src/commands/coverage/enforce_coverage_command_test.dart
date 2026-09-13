import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/coverage/enforce_coverage_command.dart';
import 'package:dev_tools/src/use_cases/coverage/enforce_coverage_threshold.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_project_root.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockEnforceCoverageThreshold extends Mock
    implements EnforceCoverageThreshold {}

class _MockFindProjectRoot extends Mock implements FindProjectRoot {}

void main() {
  late _MockEnforceCoverageThreshold checkCoverage;
  late _MockFindProjectRoot findProjectRoot;
  late EnforceCoverageCommand sut;

  setUp(() {
    checkCoverage = _MockEnforceCoverageThreshold();
    when(() => checkCoverage(
          projectRoot: any(named: 'projectRoot'),
          lcovFile: any(named: 'lcovFile'),
          threshold: any(named: 'threshold'),
        )).thenAnswer((_) async {});

    findProjectRoot = _MockFindProjectRoot();
    when(() => findProjectRoot()).thenAnswer((_) async => '/fake/root');

    sut = EnforceCoverageCommand(
      checkCoverage: checkCoverage,
      findProjectRoot: findProjectRoot,
    );
  });

  test('should expose the enforce name', () {
    expect(sut.name, EnforceCoverageCommand.commandName);
  });

  test('should describe enforcing the coverage threshold', () {
    expect(sut.description, EnforceCoverageCommand.commandDescription);
  });

  test(
      'should use the default lcov path and a 100% threshold when none is '
      'provided', () async {
    await _run(<String>[], sut);

    verify(
      () => checkCoverage(
        projectRoot: '/fake/root',
        // ignore: avoid_redundant_argument_values
        lcovFile: 'coverage/lcov.info',
        // ignore: avoid_redundant_argument_values
        threshold: 100,
      ),
    ).called(1);
  });

  test('should forward a supplied lcov path and threshold', () async {
    await _run(['--lcov-file=coverage/alt.info', '--threshold=90'], sut);

    verify(
      () => checkCoverage(
        projectRoot: '/fake/root',
        lcovFile: 'coverage/alt.info',
        threshold: 90,
      ),
    ).called(1);
  });
}

Future<void> _run(List<String> args, EnforceCoverageCommand command) async {
  final runner = CommandRunner<void>('dev_tools', '')..addCommand(command);
  await runner.run(['enforce', ...args]);
}
