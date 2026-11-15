import 'dart:io';

import 'package:dev_tools/src/utils/logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../helpers/fakes.dart';

class _MockStdout extends Mock implements Stdout {}

void main() {
  late _MockStdout out;
  late _MockStdout err;

  setUp(() {
    out = _MockStdout();
    err = _MockStdout();
  });

  void logWith(void Function(Logger logger) body) => IOOverrides.runZoned(
        () => body(const ConsoleLogger()),
        stdout: () => out,
        stderr: () => err,
      );

  test('infoShouldWriteTheMessageToStdout', () {
    logWith((logger) => logger.info('hello'));

    verify(() => out.writeln('hello')).called(1);
    verifyNever(() => err.writeln(any<Object?>()));
  });

  test('warnShouldWriteTheMessageToStderr', () {
    logWith((logger) => logger.warn('careful'));

    verify(() => err.writeln('careful')).called(1);
    verifyNever(() => out.writeln(any<Object?>()));
  });

  test('errorShouldWriteTheMessageToStderr', () {
    logWith((logger) => logger.error('broken'));

    verify(() => err.writeln('broken')).called(1);
    verifyNever(() => out.writeln(any<Object?>()));
  });

  test('logShouldAppendTheStackTraceIfOneIsGiven', () {
    final stackTrace = StackTrace.fromString('#0 main');

    logWith((logger) => logger.info('hello', stackTrace: stackTrace));

    verify(() => out.writeln('hello\n#0 main\n')).called(1);
  });

  test('withGroupedLogShouldWrapTheBodyInGroupMarkersAndReturnItsResult',
      () async {
    final logger = FakeLogger();

    final result = await logger.withGroupedLog('Build', (inner) async {
      inner.info('step');
      return 42;
    });

    expect(result, 42);
    expect(logger.messages.map((m) => m.$2), [
      '::group::Build',
      'step',
      '::endgroup::',
    ]);
  });

  test('withGroupedLogShouldCloseTheGroupIfTheBodyThrows', () async {
    final logger = FakeLogger();

    await expectLater(
      logger.withGroupedLog<void>('Build', (_) async => throw StateError('x')),
      throwsStateError,
    );
    expect(logger.messages.last.$2, '::endgroup::');
  });
}
