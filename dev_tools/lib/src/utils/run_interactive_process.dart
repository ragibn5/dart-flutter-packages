import 'package:dev_tools/src/utils/interactive_process_runner.dart';

/// Starts a process through [InteractiveProcessRunner] and waits for it.
///
/// The classes that launch external tools (`firebase`, `flutterfire`, `dart`,
/// `flutter`) take one of these, so their tests can stand in for the tool.
class RunInteractiveProcess {
  const RunInteractiveProcess();

  /// Runs [executable] with [arguments] in [workingDirectory] (default: the
  /// current one), sharing this process's terminal when [inheritStdio] is set
  /// (see [InteractiveProcessRunner.run]).
  ///
  /// Returns: the process's exit code.
  Future<int> call(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    bool inheritStdio = false,
  }) =>
      InteractiveProcessRunner(
        executable: executable,
        arguments: arguments,
        workingDirectory: workingDirectory,
        inheritStdio: inheritStdio,
      ).run();
}
