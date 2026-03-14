import 'dart:async';

import 'package:dlogger/src/constants/log_level.dart';
import 'package:dlogger/src/loggers/console_logger.dart';
import 'package:dlogger/src/models/log_data.dart';
import 'package:dlogger/src/services/log_formatter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockFormatter extends Mock implements LogFormatter {}

class _FakeLogData extends Fake implements LogData {}

void main() {
  const tag = 'TAG';
  const formattedMessage = 'formatted-message';

  late _MockFormatter mockFormatter;

  late ConsoleLogger _logger;

  setUpAll(() {
    registerFallbackValue(_FakeLogData());
  });

  setUp(() {
    mockFormatter = _MockFormatter();
    _logger = ConsoleLogger.test(mockFormatter);

    when(() => mockFormatter.format(any())).thenReturn(formattedMessage);
  });

  test('formatter is called for every log', () {
    final printed = <String>[];

    runZoned(
      () {
        _logger
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
}
