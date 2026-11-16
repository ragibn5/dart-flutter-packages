import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/whitelabel/clean_command.dart';
import 'package:dev_tools/src/use_cases/whitelabel/clean_project_artifacts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../helpers/fakes.dart';

class _MockCleanProjectArtifacts extends Mock
    implements CleanProjectArtifacts {}

void main() {
  late _MockCleanProjectArtifacts cleanProjectArtifacts;
  late CommandRunner<void> runner;

  setUp(() {
    cleanProjectArtifacts = _MockCleanProjectArtifacts();
    runner = CommandRunner<void>('dev_tools', 'test')
      ..addCommand(CleanCommand(cleanProjectArtifacts: cleanProjectArtifacts));
  });

  test('runShouldListTheRemovedArtifactsOfTheGivenProject', () async {
    when(() => cleanProjectArtifacts(any()))
        .thenAnswer((_) async => ['build', 'ios/Pods']);

    final printed = await capturePrints(
      () => runner.run(['clean', '--project', '/project']),
    );

    verify(() => cleanProjectArtifacts('/project')).called(1);
    expect(
      printed,
      'Removed 2 configured artifact(s):\n- build\n- ios/Pods\n',
    );
  });

  test('runShouldSaySoIfNothingWasRemoved', () async {
    when(() => cleanProjectArtifacts(any())).thenAnswer((_) async => []);

    final printed = await capturePrints(() => runner.run(['clean']));

    verify(() => cleanProjectArtifacts()).called(1);
    expect(printed, 'No configured artifacts found.\n');
  });

  test('runShouldRejectPositionalArguments', () {
    expect(runner.run(['clean', 'extra']), throwsA(isA<UsageException>()));
  });

  test('descriptionShouldDescribeTheCommand', () {
    expect(CleanCommand().description, CleanCommand.commandDescription);
  });
}
