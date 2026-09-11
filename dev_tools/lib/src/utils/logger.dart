import 'dart:io';

/// Reports diagnostic/progress messages, decoupled from a command's actual
/// output. Pure use cases never depend on this directly: they return data
/// (and any warning/progress text) for their caller to log; only the
/// orchestrator use case behind a command holds a [Logger] and decides
/// what, if anything, to log.
abstract interface class Logger {
  /// Reports a normal progress/status message.
  void info(String message);

  /// Reports a non-fatal problem the caller should notice.
  void warn(String message);

  /// Reports a non-fatal problem the caller should notice.
  void error(String message, {StackTrace? stackTrace});
}

/// The default [Logger]: writes [info] to stdout and [warn] to stderr.
class ConsoleLogger implements Logger {
  const ConsoleLogger();

  @override
  void info(String message) => stdout.writeln(message);

  @override
  void warn(String message) => stderr.writeln(message);

  @override
  void error(String message, {StackTrace? stackTrace}) =>
      stderr.writeln('$message\n$stackTrace');
}
