// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: avoid_redundant_argument_values

import 'package:loghub/loghub.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _FakeStackTrace implements StackTrace {
  @override
  String toString() => 'One-Liner ST';
}

void main() {
  final logRegex = RegExp(
    r'''^'''
    // Timestamp: exactly 32 chars
    r'''(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3}(?:\d{3})?Z? {0,9})'''
    // Level: exactly 8 chars
    '${LogLevel.values.map((e) => e.name.toUpperCase().padRight(8)).map(RegExp.escape).join('|')}'
    // Message: can be empty
    r'''(.*?)'''
    // Error: optional, must start on a new line after message
    r'''(?:\n(.*?))?'''
    // Stacktrace: optional, must start on a new line after error
    r'''(?:\n(.*?))?'''
    // Extras: optional, must start on a new line after stack trace
    r'''(?:\n(\w+): (.+))*'''
    r'''$''',
  );

  late _FakeStackTrace fakeStacktrace;

  setUp(() {
    fakeStacktrace = _FakeStackTrace();
  });

  int getLineCount(String msg) => msg.split('\n').length;

  // Assuming string representations of error, and,
  // all the keys and values within the extras are one-liner.
  void runForAllMessages({
    required String tag,
    required LogLevel level,
    required DateTime stamp,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
  }) {
    final messagesWithLines = [
      'This is a sample one liner message',
      'This is a sample\none liner message',
      'This is a sample\n\none liner message',
      '\nThis is a sample\none liner message',
      '\nThis is a sample\n\n\none liner message',
      'This is a sample\none liner message\n',
      'This is a sample\n\none liner message\n',
      '\nThis is a sample\none liner message\n',
      '\nThis is a sample\n\n\none liner message\n',
      '\n\nThis is a sample\n\none liner message\n\n\n',
      '\nThis is a\n\nsample one\nliner message\n',
    ];

    for (final msg in messagesWithLines) {
      final current = LogData(
        tag: tag,
        level: level,
        stamp: stamp,
        message: msg,
        error: error,
        stackTrace: stackTrace,
        extras: extras,
      );

      final prettyOutput =
          const DefaultLogFormatter(prettyPrintExtras: true).format(current);
      expect(prettyOutput, matches(logRegex));
      expect(
        getLineCount(prettyOutput),
        // Assuming string representations of error, and,
        // all the keys and values within the extras are one-liner.
        getLineCount(msg) +
            (error != null ? 1 : 0) +
            (stackTrace != null ? 1 : 0) +
            (extras?.length != null
                ? (extras!.length + (/*Start and end curly-braces*/ 2))
                : 0),
      );

      final nonPrettyOutput =
          const DefaultLogFormatter(prettyPrintExtras: false).format(current);
      expect(nonPrettyOutput, matches(logRegex));
      expect(
        getLineCount(nonPrettyOutput),
        // Assuming string representations of error, and,
        // all the keys and values within the extras are one-liner.
        getLineCount(msg) +
            (error != null ? 1 : 0) +
            (stackTrace != null ? 1 : 0) +
            (extras?.length != null ? 1 : 0),
      );
    }
  }

  test('Should validate minimum set of params', () {
    runForAllMessages(
      tag: 'TAG',
      level: LogLevel.DEBUG,
      stamp: DateTime.now(),
    );
  });

  test('Should validate full set of param', () {
    runForAllMessages(
      tag: 'TAG',
      level: LogLevel.DEBUG,
      stamp: DateTime.timestamp(),
      error: StateError('Sample state error'),
      stackTrace: fakeStacktrace,
      extras: {
        'key1': 'value1',
        'key2': 'value2',
      },
    );
  });

  test('Should validate without error', () {
    runForAllMessages(
      tag: 'TAG',
      level: LogLevel.DEBUG,
      stamp: DateTime.timestamp(),
      stackTrace: fakeStacktrace,
      extras: {
        'key1': 'value1',
        'key2': 'value2',
      },
    );
  });

  test('Should validate without stackTrace', () {
    runForAllMessages(
      tag: 'TAG',
      level: LogLevel.DEBUG,
      stamp: DateTime.timestamp(),
      error: StateError('Sample state error'),
      extras: {
        'key1': 'value1',
        'key2': 'value2',
      },
    );
  });

  test('Should validate without extras', () {
    runForAllMessages(
      tag: 'TAG',
      level: LogLevel.DEBUG,
      stamp: DateTime.timestamp(),
      error: StateError('Sample state error'),
      stackTrace: fakeStacktrace,
    );
  });
}
