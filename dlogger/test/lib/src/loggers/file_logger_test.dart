import 'dart:async';
import 'dart:io';

import 'package:dlogger/src/constants/log_level.dart';
import 'package:dlogger/src/loggers/file_logger.dart';
import 'package:dlogger/src/models/log_data.dart';
import 'package:dlogger/src/models/result.dart';
import 'package:dlogger/src/services/file_writer.dart';
import 'package:dlogger/src/services/log_formatter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

class _MockFileWriter extends Mock implements FileWriter {}

class _MockFormatter extends Mock implements LogFormatter {}

class _FakeFile extends Fake implements File {}

class _FakeLogData extends Fake implements LogData {}

class _FakeFileMode extends Fake implements FileMode {}

void main() {
  group('FileLogger', () {
    const tag = 'TAG';
    const modeParamKey = 'mode';
    const formattedMessage = 'formatted-message';
    final tempDir =
        Directory('${Directory.systemTemp.path}${path.separator}logs');

    late _MockFileWriter mockWriter;
    late _MockFormatter mockFormatter;
    late StreamController<LogData> controller;

    late FileLogger logger;

    String tempFileNameBuilder(LogData data) => 'log-${data.level}.txt';

    setUpAll(() {
      registerFallbackValue(_FakeFile());
      registerFallbackValue(_FakeLogData());
      registerFallbackValue(_FakeFileMode());
    });

    setUp(() {
      mockWriter = _MockFileWriter();
      mockFormatter = _MockFormatter();

      controller = StreamController<LogData>();

      logger = FileLogger.test(
        tempDir,
        tempFileNameBuilder,
        mockFormatter,
        mockWriter,
        controller,
      );

      tempDir.createSync(recursive: true);

      when(() => mockFormatter.format(any())).thenReturn(formattedMessage);
      when(() => mockWriter.writeSync(any(), any(),
          mode: any(named: modeParamKey))).thenReturn(Result.success(null));
    });

    tearDown(() {
      controller.close();
      tempDir.deleteSync(recursive: true);
    });

    test('no writes after dispose', () async {
      logger
        ..dispose()
        ..log(
          LogData(
            tag: tag,
            level: LogLevel.INFO,
            stamp: DateTime.now(),
            message: 'post-dispose',
          ),
        );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      verifyNever(
        () => mockWriter.writeSync(
          any(),
          any(),
          mode: any(named: modeParamKey),
        ),
      );
    });

    test('writes to correct file', () async {
      final data = LogData(
        level: LogLevel.DEBUG,
        stamp: DateTime.now(),
        message: 'message',
        tag: tag,
      );
      final expectedFile =
          File('${tempDir.path}${path.separator}${tempFileNameBuilder(data)}');

      logger.log(data);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      verify(
        () => mockWriter.writeSync(
          any(that: predicate<File>((f) => f.path == expectedFile.path)),
          any(),
          mode: any(named: modeParamKey),
        ),
      ).called(1);
    });

    test('writes correct data', () async {
      const expectedMessage = formattedMessage;
      final data = LogData(
        level: LogLevel.DEBUG,
        stamp: DateTime.now(),
        message: 'message',
        tag: tag,
      );
      when(() => mockFormatter.format(any())).thenReturn(expectedMessage);

      logger.log(data);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      verify(
        () => mockWriter.writeSync(
          any(),
          expectedMessage,
          mode: any(named: modeParamKey),
        ),
      ).called(1);
    });

    test('writes in correct mode', () async {
      logger.log(
        LogData(
          level: LogLevel.DEBUG,
          message: 'message',
          stamp: DateTime.now(),
          tag: tag,
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      verify(
        () => mockWriter.writeSync(
          any(),
          any(),
          mode: FileMode.append,
        ),
      ).called(1);
    });

    test('dispose closes stream', () async {
      logger.dispose();

      expect(controller.isClosed, true);
    });

    test('multiple logs trigger multiple writes in order', () async {
      const count = 100;
      final msgIdList = <int>[];

      when(() => mockFormatter.format(any())).thenAnswer((call) {
        return (call.positionalArguments[0] as LogData).message;
      });
      when(
        () => mockWriter.writeSync(
          any(),
          any(),
          mode: any(named: modeParamKey),
        ),
      ).thenAnswer((call) {
        final message = call.positionalArguments[1] as String;
        final index = int.parse(message.split('-')[1]);
        msgIdList.add(index);

        // Simulate varying processing times
        sleep(Duration(milliseconds: count - index));

        // print('Logged: $message');
        return Result.success(null);
      });

      // Log all messages
      for (var i = 0; i < count; ++i) {
        logger.log(
          LogData(
              tag: tag,
              level: LogLevel.DEBUG,
              stamp: DateTime.now(),
              message: 'm-$i'),
        );
      }

      // Wait long enough for all writes to complete
      await Future<void>.delayed(
        // 1000 ms is just to be sure everything is completed
        const Duration(milliseconds: (count * count) + 1000),
      );

      // Verify all messages were written in order
      expect(msgIdList.length, count);
      for (var i = 0; i < count; ++i) {
        expect(msgIdList[i], i, reason: 'Message at index $i should be $i');
      }
    });
  });
}
