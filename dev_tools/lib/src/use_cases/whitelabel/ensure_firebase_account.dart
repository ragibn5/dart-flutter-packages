import 'package:dev_tools/src/use_cases/whitelabel/firebase_setup_exception.dart';
import 'package:dev_tools/src/utils/prompter.dart';
import 'package:dev_tools/src/utils/run_interactive_process.dart';
import 'package:meta/meta.dart';

/// Shows the Firebase CLI's active account and offers to switch it before
/// configuring a project.
class EnsureFirebaseAccount {
  final Prompter _prompter;
  final RunInteractiveProcess _runInteractiveProcess;

  const EnsureFirebaseAccount({
    Prompter prompter = const ConsolePrompter(),
    @visibleForTesting
    RunInteractiveProcess runInteractiveProcess = const RunInteractiveProcess(),
  })  : _prompter = prompter,
        _runInteractiveProcess = runInteractiveProcess;

  /// Runs `firebase login` (a no-op if already authenticated), prints the
  /// active account via `firebase login:list`, then optionally logs out and
  /// back in as a different one.
  ///
  /// Returns: nothing (void).
  ///
  /// Throws:
  /// - [FirebaseSetupException] when a `firebase` invocation exits with a
  ///   non-zero code.
  Future<void> call() async {
    await _runFirebase(['login']);
    await _runFirebase(['login:list']);

    _prompter.write(
      '0 to continue\n'
      '1 to logout and login and continue\n'
      'Enter choice [0/1]: ',
    );
    if ((_prompter.readLine() ?? '').trim() == '1') {
      await _runFirebase(['logout']);
      await _runFirebase(['login']);
    }
  }

  Future<void> _runFirebase(List<String> arguments) async {
    final exitCode = await _runInteractiveProcess(
      'firebase',
      arguments,
      inheritStdio: true,
    );
    if (exitCode != 0) {
      throw FirebaseSetupException(
        'firebase ${arguments.join(' ')} exited with code $exitCode.',
      );
    }
  }
}
