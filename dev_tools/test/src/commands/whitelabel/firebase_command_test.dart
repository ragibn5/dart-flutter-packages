import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/whitelabel/firebase_command.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_project_root.dart';
import 'package:dev_tools/src/use_cases/whitelabel/run_firebase_setup.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockFindProjectRoot extends Mock implements FindProjectRoot {}

class _MockRunFirebaseSetup extends Mock implements RunFirebaseSetup {}

void main() {
  late _MockFindProjectRoot findProjectRoot;
  late _MockRunFirebaseSetup runFirebaseSetup;
  late CommandRunner<void> runner;

  setUp(() {
    findProjectRoot = _MockFindProjectRoot();
    runFirebaseSetup = _MockRunFirebaseSetup();
    when(() => findProjectRoot(any())).thenAnswer((_) async => '/root');
    when(() => runFirebaseSetup(any(), any())).thenAnswer((_) async {});
    runner = CommandRunner<void>('dev_tools', 'test')
      ..addCommand(
        FirebaseCommand(
          findProjectRoot: findProjectRoot,
          runFirebaseSetup: runFirebaseSetup,
        ),
      );
  });

  test('runShouldSetUpTheGivenFlavorOfTheGivenProject', () async {
    await runner.run(['firebase', '-p', '/project', 'prod']);

    verify(() => findProjectRoot('/project')).called(1);
    verify(() => runFirebaseSetup('/root', 'prod')).called(1);
  });

  test('runShouldSetUpDefaultIfNoFlavorIsGiven', () async {
    await runner.run(['firebase']);

    verify(() => runFirebaseSetup('/root', 'default')).called(1);
  });

  test('runShouldRejectMoreThanOneFlavor', () {
    expect(
      runner.run(['firebase', 'dev', 'prod']),
      throwsA(isA<UsageException>()),
    );
  });

  test('descriptionShouldDescribeTheCommand', () {
    expect(FirebaseCommand().description, FirebaseCommand.commandDescription);
  });
}
