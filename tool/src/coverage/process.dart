import 'dart:io';

/// Runs [executable] with [args], sharing this process's terminal; exits with
/// its exit code when it fails.
Future<void> run(String executable, List<String> args) async {
  final process = await Process.start(
    executable,
    args,
    mode: ProcessStartMode.inheritStdio,
  );
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    fail('`$executable ${args.join(' ')}` exited with $exitCode', exitCode);
  }
}

/// Prints [message] to stderr and exits with [exitCode].
Never fail(String message, [int exitCode = 1]) {
  stderr.writeln(message);
  exit(exitCode);
}
