import 'dart:async';

import 'package:dev_tools/src/utils/logger.dart';
import 'package:dev_tools/src/utils/prompter.dart';
import 'package:dev_tools/src/utils/run_interactive_process.dart';

/// A [Prompter] that answers from the inputs it's given, in order (null once
/// they run out, as at end of input), and records everything written.
class FakePrompter implements Prompter {
  final List<String?> _inputs;
  final StringBuffer _output = StringBuffer();

  FakePrompter([List<String?> inputs = const []]) : _inputs = [...inputs];

  /// Everything written so far.
  String get output => _output.toString();

  @override
  void write(String message) => _output.write(message);

  @override
  String? readLine() => _inputs.isEmpty ? null : _inputs.removeAt(0);
}

/// A [Logger] that records each message with its level.
class FakeLogger extends Logger {
  final List<(LogLevel, String)> messages = [];

  @override
  void log(LogLevel level, String message, {StackTrace? stackTrace}) =>
      messages.add((level, message));
}

/// One [FakeRunInteractiveProcess] call.
typedef ProcessCall = ({
  String executable,
  List<String> arguments,
  String? workingDirectory,
  bool inheritStdio,
});

/// A [RunInteractiveProcess] that starts nothing: it records each call, runs
/// [onRun] (to stand in for what the tool would do), and returns [exitCode].
class FakeRunInteractiveProcess implements RunInteractiveProcess {
  final int exitCode;
  final FutureOr<void> Function(ProcessCall call)? onRun;
  final List<ProcessCall> calls = [];

  FakeRunInteractiveProcess({this.exitCode = 0, this.onRun});

  @override
  Future<int> call(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    bool inheritStdio = false,
  }) async {
    final call = (
      executable: executable,
      arguments: arguments,
      workingDirectory: workingDirectory,
      inheritStdio: inheritStdio,
    );
    calls.add(call);
    await onRun?.call(call);
    return exitCode;
  }
}

/// Runs [body] and returns everything it printed.
Future<String> capturePrints(FutureOr<void> Function() body) async {
  final printed = StringBuffer();
  await runZoned(
    () async => body(),
    zoneSpecification: ZoneSpecification(
      print: (_, __, ___, line) => printed.writeln(line),
    ),
  );
  return printed.toString();
}
