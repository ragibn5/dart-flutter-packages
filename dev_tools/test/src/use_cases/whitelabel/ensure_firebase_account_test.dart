import 'package:dev_tools/src/use_cases/whitelabel/ensure_firebase_account.dart';
import 'package:dev_tools/src/use_cases/whitelabel/firebase_setup_exception.dart';
import 'package:test/test.dart';

import '../../../helpers/fakes.dart';

void main() {
  test('callShouldLogInAndListTheAccountIfTheUserContinues', () async {
    final process = FakeRunInteractiveProcess();
    final prompter = FakePrompter(['0']);

    await EnsureFirebaseAccount(
      prompter: prompter,
      runInteractiveProcess: process,
    )();

    expect(process.calls.map((c) => c.executable), ['firebase', 'firebase']);
    expect(process.calls.map((c) => c.arguments), [
      ['login'],
      ['login:list'],
    ]);
    expect(process.calls.every((c) => c.inheritStdio), isTrue);
    expect(prompter.output, contains('Enter choice [0/1]: '));
  });

  test('callShouldLogOutAndBackInIfTheUserSwitchesAccount', () async {
    final process = FakeRunInteractiveProcess();

    await EnsureFirebaseAccount(
      prompter: FakePrompter(['1']),
      runInteractiveProcess: process,
    )();

    expect(process.calls.map((c) => c.arguments.single), [
      'login',
      'login:list',
      'logout',
      'login',
    ]);
  });

  test('callShouldThrowIfAFirebaseCommandFails', () async {
    expect(
      EnsureFirebaseAccount(
        prompter: FakePrompter(),
        runInteractiveProcess: FakeRunInteractiveProcess(exitCode: 2),
      )(),
      throwsA(
        isA<FirebaseSetupException>().having(
          (e) => e.message,
          'message',
          'firebase login exited with code 2.',
        ),
      ),
    );
  });
}
