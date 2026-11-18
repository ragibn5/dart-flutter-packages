import 'dart:async';

import 'package:content_io_android/src/exceptions/content_read_exception.dart';
import 'package:content_io_android/src/io/session/content_read_session.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_content_reader.dart';

void main() {
  test('sessionIdShouldBeReaderId', () {
    final session = ContentReadSession(
      reader: FakeContentReader(id: 'session-1'),
    );

    expect(session.sessionId, 'session-1');
  });

  test('sizeInBytesShouldBeReaderLength', () {
    final session = ContentReadSession(reader: FakeContentReader(length: 2048));

    expect(session.sizeInBytes, 2048);
  });

  group('openRead', () {
    test('openReadShouldThrowRangeErrorIfChunkSizeIsNotPositive', () {
      final session = ContentReadSession(reader: FakeContentReader());

      expect(() => session.openRead(chunkSize: 0), throwsRangeError);
    });

    test('openReadShouldThrowStateErrorIfSessionWasAlreadyRead', () async {
      final session = ContentReadSession(reader: FakeContentReader());
      await session.readAsBytes();

      expect(session.openRead, throwsStateError);
    });

    test('openReadShouldStreamChunksUntilReaderIsExhausted', () async {
      final reader = FakeContentReader(
        pieces: [
          [1, 2],
          [3],
        ],
      );
      final session = ContentReadSession(reader: reader);

      expect(await session.openRead().toList(), [
        [1, 2],
        [3],
      ]);
    });

    test('openReadShouldReadChunksOfChunkSize', () async {
      final reader = FakeContentReader(
        pieces: [
          [1, 2],
        ],
      );

      await ContentReadSession(
        reader: reader,
      ).openRead(chunkSize: 2).drain<void>();

      expect(reader.readLengths, everyElement(2));
    });

    test('openReadShouldCloseSessionIfStreamCompletes', () async {
      final reader = FakeContentReader();
      final session = ContentReadSession(reader: reader);

      await session.openRead().drain<void>();

      expect(session.isClosed, isTrue);
      expect(reader.closeCount, 1);
    });

    test('openReadShouldDeliverErrorAndCloseSessionIfReadFails', () async {
      final reader = FakeContentReader()..readError = const ReadException('io');
      final session = ContentReadSession(reader: reader);

      await expectLater(session.openRead(), emitsError(isA<ReadException>()));
      expect(reader.closeCount, 1);
    });

    test('openReadShouldCloseSessionIfSubscriptionIsCancelled', () async {
      final reader = FakeContentReader(
        pieces: [
          [1],
          [2],
        ],
      );
      final session = ContentReadSession(reader: reader);

      await session.openRead().first;

      expect(reader.closeCount, 1);
    });

    test(
      'openReadShouldDeliverSessionNotFoundExceptionIfSessionIsClosed',
      () async {
        final session = ContentReadSession(reader: FakeContentReader());
        await session.close();

        await expectLater(
          session.openRead(),
          emitsError(isA<SessionNotFoundException>()),
        );
      },
    );
  });

  group('readAsBytes', () {
    test('readAsBytesShouldThrowStateErrorIfSessionWasAlreadyRead', () async {
      final session = ContentReadSession(reader: FakeContentReader());
      await session.openRead().drain<void>();

      expect(session.readAsBytes, throwsStateError);
    });

    test('readAsBytesShouldReturnWholeItemAndCloseSession', () async {
      final reader = FakeContentReader(
        pieces: [
          [1, 2],
          [3],
        ],
      );
      final session = ContentReadSession(reader: reader);

      expect(await session.readAsBytes(), [1, 2, 3]);
      expect(reader.closeCount, 1);
    });

    test('readAsBytesShouldThrowAndCloseSessionIfReadFails', () async {
      final reader = FakeContentReader()..readError = const ReadException('io');
      final session = ContentReadSession(reader: reader);

      await expectLater(session.readAsBytes(), throwsA(isA<ReadException>()));
      expect(reader.closeCount, 1);
    });

    test(
      'readAsBytesShouldThrowSessionNotFoundExceptionIfSessionIsClosed',
      () async {
        final session = ContentReadSession(reader: FakeContentReader());
        await session.close();

        expect(session.readAsBytes(), throwsA(isA<SessionNotFoundException>()));
      },
    );
  });

  group('close', () {
    test('closeShouldCloseReaderOnceIfCalledTwice', () async {
      final reader = FakeContentReader();
      final session = ContentReadSession(reader: reader);

      await session.close();
      await session.close();

      expect(reader.closeCount, 1);
    });

    test('closeShouldWaitForReadInProgress', () async {
      final gate = Completer<void>();
      final reader = FakeContentReader()..readAllGate = gate;
      final session = ContentReadSession(reader: reader);

      final read = session.readAsBytes();
      final close = session.close();
      await Future<void>.delayed(Duration.zero);
      expect(reader.closeCount, 0);

      gate.complete();
      await read;
      await close;
      expect(reader.closeCount, 1);
    });
  });
}
