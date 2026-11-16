import 'dart:io';

import 'package:dev_tools/src/utils/logger.dart';

/// Reads/writes a single interactive prompt: unlike [Logger], the write and
/// the read are one indivisible exchange the caller's control flow depends
/// on, not optional commentary — so it's never silenced or redirected
/// independently of the read it belongs to.
abstract interface class Prompter {
  /// Writes [message] without a trailing newline (the input is expected on
  /// the same line).
  void write(String message);

  /// Reads a line of input, or null at end of input.
  String? readLine();
}

/// The default [Prompter]: writes to stdout, reads from stdin.
class ConsolePrompter implements Prompter {
  const ConsolePrompter();

  @override
  void write(String message) => stdout.write(message);

  @override
  String? readLine() => stdin.readLineSync();
}
