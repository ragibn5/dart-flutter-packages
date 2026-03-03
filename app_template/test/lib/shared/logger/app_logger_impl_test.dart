// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/shared/logger/app_logger_impl.dart';
import 'package:dlogger/dlogger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCompositeLogger extends Mock implements CompositeLogger {}

class _FakeLogData extends Mock implements LogData {}

void main() {
  const debugTag = 'DEBUG_TAG';
  const infoTag = 'INFO_TAG';
  const warnTag = 'WARN_TAG';
  const errorTag = 'ERROR_TAG';
  const debugMessage = 'debug message';
  const infoMessage = 'info message';
  const warnMessage = 'warn message';
  const errorMessage = 'error message';
  final errorObject = StateError('something went wrong');
  final extrasObject = {'key': 'value'};

  late _MockCompositeLogger mockCompositeLogger;

  late AppLoggerImpl appLogger;

  setUpAll(() {
    registerFallbackValue(_FakeLogData());
  });

  setUp(() {
    mockCompositeLogger = _MockCompositeLogger();
    appLogger = AppLoggerImpl.test(mockCompositeLogger);
  });

  /// Generic helper to verify a log call
  void verifyLog({
    required void Function() logMethod,
    required LogLevel expectedLevel,
    required String expectedTag,
    required String expectedMessage,
    Error? expectedError,
    Map<String, dynamic>? expectedExtras,
  }) {
    logMethod();

    final captured = verify(
      () => mockCompositeLogger.log(captureAny()),
    ).captured;
    expect(captured.single, isA<LogData>());
    final logData = captured.single as LogData;

    expect(logData.level, expectedLevel);
    expect(logData.tag, expectedTag);
    expect(logData.message, expectedMessage);
    expect(logData.error, expectedError);
    expect(logData.extras, expectedExtras);
  }

  test('logDebug forwards correct LogData', () {
    verifyLog(
      logMethod: () => appLogger.logDebug(tag: debugTag, message: debugMessage),
      expectedLevel: LogLevel.DEBUG,
      expectedTag: debugTag,
      expectedMessage: debugMessage,
    );
  });

  test('logInfo forwards correct LogData', () {
    verifyLog(
      logMethod: () => appLogger.logInfo(tag: infoTag, message: infoMessage),
      expectedLevel: LogLevel.INFO,
      expectedTag: infoTag,
      expectedMessage: infoMessage,
    );
  });

  test('logWarning forwards correct LogData', () {
    verifyLog(
      logMethod: () => appLogger.logWarning(tag: warnTag, message: warnMessage),
      expectedLevel: LogLevel.WARNING,
      expectedTag: warnTag,
      expectedMessage: warnMessage,
    );
  });

  test('logError forwards correct LogData', () {
    verifyLog(
      logMethod: () => appLogger.logError(
        tag: errorTag,
        message: errorMessage,
        error: errorObject,
        extras: extrasObject,
      ),
      expectedLevel: LogLevel.ERROR,
      expectedTag: errorTag,
      expectedMessage: errorMessage,
      expectedError: errorObject,
      expectedExtras: extrasObject,
    );
  });
}
