import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/src/exceptions/media_read_exception.dart';
import 'package:media_provider_android/src/io/session/media_read_session.dart';

import '../../../helpers/fake_byte_source.dart';

void main() {
  test('sessionIdShouldBeSourceId', () {
    final session = MediaReadSession(source: FakeByteSource(id: 'session-1'));

    expect(session.sessionId, 'session-1');
  });

  test('sizeInBytesShouldBeSourceLength', () {
    final session = MediaReadSession(source: FakeByteSource(length: 2048));

    expect(session.sizeInBytes, 2048);
  });

  group('openRead', () {
    test('openReadShouldThrowRangeErrorIfChunkSizeIsNotPositive', () {
      final session = MediaReadSession(source: FakeByteSource());

      expect(() => session.openRead(chunkSize: 0), throwsRangeError);
    });

    test('openReadShouldThrowStateErrorIfSessionWasAlreadyRead', () async {
      final session = MediaReadSession(source: FakeByteSource());
      await session.readAsBytes();

      expect(session.openRead, throwsStateError);
    });

    test('openReadShouldStreamChunksUntilSourceIsExhausted', () async {
      final source = FakeByteSource(
        pieces: [
          [1, 2],
          [3],
        ],
      );
      final session = MediaReadSession(source: source);

      expect(await session.openRead().toList(), [
        [1, 2],
        [3],
      ]);
    });

    test('openReadShouldReadChunksOfChunkSize', () async {
      final source = FakeByteSource(
        pieces: [
          [1, 2],
        ],
      );

      await MediaReadSession(
        source: source,
      ).openRead(chunkSize: 2).drain<void>();

      expect(source.readLengths, everyElement(2));
    });

    test('openReadShouldCloseSessionIfStreamCompletes', () async {
      final source = FakeByteSource();
      final session = MediaReadSession(source: source);

      await session.openRead().drain<void>();

      expect(session.isClosed, isTrue);
      expect(source.closeCount, 1);
    });

    test('openReadShouldDeliverErrorAndCloseSessionIfReadFails', () async {
      final source = FakeByteSource()..readError = const ReadException('io');
      final session = MediaReadSession(source: source);

      await expectLater(session.openRead(), emitsError(isA<ReadException>()));
      expect(source.closeCount, 1);
    });

    test('openReadShouldCloseSessionIfSubscriptionIsCancelled', () async {
      final source = FakeByteSource(
        pieces: [
          [1],
          [2],
        ],
      );
      final session = MediaReadSession(source: source);

      await session.openRead().first;

      expect(source.closeCount, 1);
    });

    test(
      'openReadShouldDeliverSessionNotFoundExceptionIfSessionIsClosed',
      () async {
        final session = MediaReadSession(source: FakeByteSource());
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
      final session = MediaReadSession(source: FakeByteSource());
      await session.openRead().drain<void>();

      expect(session.readAsBytes, throwsStateError);
    });

    test('readAsBytesShouldReturnWholeItemAndCloseSession', () async {
      final source = FakeByteSource(
        pieces: [
          [1, 2],
          [3],
        ],
      );
      final session = MediaReadSession(source: source);

      expect(await session.readAsBytes(), [1, 2, 3]);
      expect(source.closeCount, 1);
    });

    test('readAsBytesShouldThrowAndCloseSessionIfReadFails', () async {
      final source = FakeByteSource()..readError = const ReadException('io');
      final session = MediaReadSession(source: source);

      await expectLater(session.readAsBytes(), throwsA(isA<ReadException>()));
      expect(source.closeCount, 1);
    });

    test(
      'readAsBytesShouldThrowSessionNotFoundExceptionIfSessionIsClosed',
      () async {
        final session = MediaReadSession(source: FakeByteSource());
        await session.close();

        expect(session.readAsBytes(), throwsA(isA<SessionNotFoundException>()));
      },
    );
  });

  group('close', () {
    test('closeShouldCloseSourceOnceIfCalledTwice', () async {
      final source = FakeByteSource();
      final session = MediaReadSession(source: source);

      await session.close();
      await session.close();

      expect(source.closeCount, 1);
    });

    test('closeShouldWaitForReadInProgress', () async {
      final gate = Completer<void>();
      final source = FakeByteSource()..readAllGate = gate;
      final session = MediaReadSession(source: source);

      final read = session.readAsBytes();
      final close = session.close();
      await Future<void>.delayed(Duration.zero);
      expect(source.closeCount, 0);

      gate.complete();
      await read;
      await close;
      expect(source.closeCount, 1);
    });
  });
}
