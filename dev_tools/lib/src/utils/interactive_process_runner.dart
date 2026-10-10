import 'dart:async';
import 'dart:io';

class InteractiveProcessRunner {
  final String _executable;
  final List<String> _arguments;
  final IOSink _stdout;
  final IOSink _stderr;
  final Stream<List<int>>? _stdin;
  final String? _workingDirectory;
  final bool _inheritStdio;

  InteractiveProcessRunner({
    required String executable,
    required List<String> arguments,
    String? workingDirectory,
    IOSink? stdOut,
    IOSink? stdErr,
    Stream<List<int>>? stdIn,
    bool inheritStdio = false,
  })  : _executable = executable,
        _arguments = arguments,
        _workingDirectory = workingDirectory,
        _stdout = stdOut ?? stdout,
        _stderr = stdErr ?? stderr,
        _stdin = stdIn,
        _inheritStdio = inheritStdio;

  /// Runs the process.
  ///
  /// When `inheritStdio` was set, the child is given this process's actual
  /// terminal file descriptors directly (`ProcessStartMode.inheritStdio`),
  /// rather than piped streams forwarded byte-for-byte. Some tools (e.g.
  /// `firebase login`) check whether their stdio is a real TTY and behave
  /// differently — even refusing to run — when it's only a pipe; this mode
  /// is for those. The `stdOut`/`stdErr`/`stdIn` overrides have no effect in
  /// this mode, since there are no streams to intercept.
  Future<int> run() async {
    if (_inheritStdio) {
      final process = await Process.start(
        _executable,
        _arguments,
        workingDirectory: _workingDirectory,
        mode: ProcessStartMode.inheritStdio,
      );
      return process.exitCode;
    }

    final process = await Process.start(
      _executable,
      _arguments,
      workingDirectory: _workingDirectory,
    );

    final stdoutDone = process.stdout.forEach(_stdout.add);
    final stderrDone = process.stderr.forEach(_stderr.add);
    final futures = <Future<void>>[stdoutDone, stderrDone];
    if (_stdin != null) {
      futures.add(process.stdin.addStream(_stdin!));
    } else {
      await process.stdin.close();
    }
    await Future.wait(futures);

    return process.exitCode;
  }
}
