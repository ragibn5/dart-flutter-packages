import 'package:app_logger/src/app_logger_factory.dart';
import 'package:loghub/loghub.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockLogger extends Mock implements Logger {}

class _FakeLogData extends Fake implements LogData {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeLogData());
  });

  test('createShouldLogToTheGivenLoggersIfCalled', () {
    final mockLogger = _MockLogger();
    // Not const, so the constructor runs and counts for coverage.
    // ignore: prefer_const_constructors
    AppLoggerFactory().create(loggers: {'logger': mockLogger}).logInfo(
        tag: 'tag', message: 'message');

    final logged =
        verify(() => mockLogger.log(captureAny())).captured.single as LogData;
    expect(logged.tag, 'tag');
    expect(logged.message, 'message');
    expect(logged.level, LogLevel.INFO);
  });
}
