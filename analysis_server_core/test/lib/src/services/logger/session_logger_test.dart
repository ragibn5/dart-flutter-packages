// ignore_for_file: lines_longer_than_80_chars

import 'package:analysis_server_core/src/services/logger/session_logger.dart';
import 'package:dlogger/dlogger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _FakeLogData extends Mock implements LogData {}

class _MockCompositeLogger extends Mock implements CompositeLogger {}

void main() {
  const tag = 'TAG';
  const msg = 'MESSAGE';

  late _MockCompositeLogger mockCompositeLogger;

  late SessionLogger sut;

  void verifyLoggedLevel(
    _MockCompositeLogger logger, {
    required LogLevel level,
    required String tag,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extras,
    int called = 1,
  }) {
    if (called == 0) {
      verifyNever(
        () => logger.log(
          any(that: isA<LogData>().having((d) => d.level, 'level', level)),
        ),
      );
      return;
    }

    verify(
      () => logger.log(
        any(
          that: isA<LogData>()
              .having((d) => d.level, 'level', level)
              .having((d) => d.tag, 'tag', tag)
              .having((d) => d.message, 'message', message)
              .having((d) => d.error, 'error', error)
              .having((d) => d.stackTrace, 'stackTrace', stackTrace)
              .having((d) => d.extras, 'extras', extras),
        ),
      ),
    ).called(called);
  }

  void runLevelCombinationCheck({
    required bool info,
    required bool warning,
    required bool error,
  }) {
    // Reset mock so previous invocations don't interfere
    reset(mockCompositeLogger);

    sut
      ..setLevelStatus(SessionLogLevel.INFO, enabled: info)
      ..setLevelStatus(SessionLogLevel.WARNING, enabled: warning)
      ..setLevelStatus(SessionLogLevel.ERROR, enabled: error)
      ..logInfo(tag: tag, message: msg)
      ..logWarning(tag: tag, message: msg)
      ..logError(tag: tag, message: msg);

    verifyLoggedLevel(
      mockCompositeLogger,
      level: LogLevel.INFO,
      tag: tag,
      message: msg,
      called: info ? 1 : 0,
    );

    verifyLoggedLevel(
      mockCompositeLogger,
      level: LogLevel.WARNING,
      tag: tag,
      message: msg,
      called: warning ? 1 : 0,
    );

    verifyLoggedLevel(
      mockCompositeLogger,
      level: LogLevel.ERROR,
      tag: tag,
      message: msg,
      called: error ? 1 : 0,
    );
  }

  setUpAll(() {
    registerFallbackValue(_FakeLogData());
  });

  setUp(() {
    mockCompositeLogger = _MockCompositeLogger();
    sut = SessionLoggerImpl.test(
      mockCompositeLogger,
      enabled: true,
      allowedLevels: SessionLogLevel.values.toSet(),
    );

    when(() => mockCompositeLogger.log(any())).thenAnswer((_) {});
  });

  test('Default constructor should: enable logger + enable all levels', () {
    final SessionLogger localSUT = SessionLoggerImpl({
      'x': mockCompositeLogger,
    });
    expect(localSUT.enabled, true);
    expect(localSUT.allowedLevels, SessionLogLevel.values.toSet());
  });

  test('Calling `setEnabled` should enable/disable the logger', () {
    sut
      ..setEnabled(enabled: true)
      ..logInfo(tag: tag, message: msg)
      ..logWarning(tag: tag, message: msg)
      ..logError(tag: tag, message: msg)
      ..setEnabled(enabled: false)
      ..logInfo(tag: tag, message: msg)
      ..logWarning(tag: tag, message: msg)
      ..logError(tag: tag, message: msg)
      ..setEnabled(enabled: true)
      ..logInfo(tag: tag, message: msg)
      ..logWarning(tag: tag, message: msg)
      ..logError(tag: tag, message: msg);

    verify(() => mockCompositeLogger.log(any())).called(6);
  });

  test('Calling `setLevelStatus` should enable/disable the log level', () {
    runLevelCombinationCheck(info: false, warning: false, error: false);
    runLevelCombinationCheck(info: true, warning: false, error: false);
    runLevelCombinationCheck(info: false, warning: true, error: false);
    runLevelCombinationCheck(info: false, warning: false, error: true);
    runLevelCombinationCheck(info: true, warning: true, error: false);
    runLevelCombinationCheck(info: true, warning: false, error: true);
    runLevelCombinationCheck(info: false, warning: true, error: true);
    runLevelCombinationCheck(info: true, warning: true, error: true);
  });
}
