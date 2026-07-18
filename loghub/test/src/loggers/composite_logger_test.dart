import 'package:loghub/loghub.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockLogger extends Mock implements Logger {}

class _MockFilter extends Mock implements LogFilter {}

class _FakeLogData extends Fake implements LogData {}

void main() {
  const tag = 'TAG';

  late _MockLogger mockLogger1;
  late _MockLogger mockLogger2;
  late _MockFilter mockFilter1;
  late _MockFilter mockFilter2;
  late List<LogFilter> mockFilters;
  late Map<String, Logger> mockLoggers;

  late CompositeLogger sut;

  setUpAll(() {
    registerFallbackValue(_FakeLogData());
  });

  setUp(() {
    mockLogger1 = _MockLogger();
    mockLogger2 = _MockLogger();
    mockFilter1 = _MockFilter();
    mockFilter2 = _MockFilter();
    mockFilters = [mockFilter1, mockFilter2];
    mockLoggers = {
      'logger1': mockLogger1,
      'logger2': mockLogger2,
    };

    when(() => mockLogger1.log(any())).thenReturn(null);
    when(() => mockLogger2.log(any())).thenReturn(null);
    when(
      () => mockFilter1.shouldBlock(any(), loggerId: any(named: 'loggerId')),
    ).thenReturn(false);
    when(
      () => mockFilter2.shouldBlock(any(), loggerId: any(named: 'loggerId')),
    ).thenReturn(false);

    sut = CompositeLogger(mockLoggers, mockFilters);
  });

  test("If any filter blocks, shouldn't call any injected sut's log method",
      () {
    when(
      () => mockFilter1.shouldBlock(any(), loggerId: any(named: 'loggerId')),
    ).thenReturn(true);
    when(
      () => mockFilter2.shouldBlock(any(), loggerId: any(named: 'loggerId')),
    ).thenReturn(false);

    sut.log(
      LogData(
        tag: tag,
        level: LogLevel.INFO,
        stamp: DateTime.now(),
        message: 'message',
      ),
    );

    verifyNever(() => mockLogger1.log(any()));
    verifyNever(() => mockLogger2.log(any()));
  });

  test("If no filter blocks, should invoke all injected sut's log method", () {
    final logData = LogData(
      tag: tag,
      level: LogLevel.INFO,
      stamp: DateTime.now(),
      message: 'message',
    );

    sut.log(logData);

    verify(() => mockLogger1.log(logData)).called(1);
    verify(() => mockLogger2.log(logData)).called(1);
  });
}
