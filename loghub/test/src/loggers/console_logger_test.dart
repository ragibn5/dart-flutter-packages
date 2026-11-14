import 'dart:async';

import 'package:loghub/src/constants/log_level.dart';
import 'package:loghub/src/loggers/console_logger.dart';
import 'package:loghub/src/models/log_data.dart';
import 'package:loghub/src/services/default_log_formatter.dart';
import 'package:loghub/src/services/log_formatter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockFormatter extends Mock implements LogFormatter {}

class _FakeLogData extends Fake implements LogData {}

void main() {
  const tag = 'TAG';
  const formattedMessage = 'formatted-message';

  late _MockFormatter mockFormatter;

  late ConsoleLogger sut;

  setUpAll(() {
    registerFallbackValue(_FakeLogData());
  });

  setUp(() {
    mockFormatter = _MockFormatter();

    sut = ConsoleLogger.test(mockFormatter);

    when(() => mockFormatter.format(any())).thenReturn(formattedMessage);
  });

  test('formatter is called for every log', () {
    final printed = <String>[];

    runZoned(
      () {
        sut
          ..log(
            LogData(
              tag: tag,
              level: LogLevel.WARNING,
              stamp: DateTime.now(),
              message: 'm1',
            ),
          )
          ..log(
            LogData(
              tag: tag,
              level: LogLevel.ERROR,
              stamp: DateTime.now(),
              message: 'm2',
            ),
          );
      },
      zoneSpecification: ZoneSpecification(
        print: (_, __, ___, msg) => printed.add(msg),
      ),
    );

    expect(printed.length, 2);
    verify(() => mockFormatter.format(any())).called(2);
  });

  test('publicConstructorShouldPrintWithTheDefaultFormatterIfNoneIsGiven', () {
    final data = LogData(
      level: LogLevel.INFO,
      stamp: DateTime(2026, 11, 14),
      message: 'message',
      tag: tag,
    );
    final printed = <String>[];

    runZoned(
      () => ConsoleLogger().log(data),
      zoneSpecification: ZoneSpecification(
        print: (_, __, ___, line) => printed.add(line),
      ),
    );

    expect(printed, [const DefaultLogFormatter().format(data)]);
  });
}
