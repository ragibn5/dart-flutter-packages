import 'dart:async';
import 'dart:typed_data';

import 'package:content_io_android/src/exceptions/content_write_exception.dart';
import 'package:content_io_android/src/io/session/content_write_session.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_byte_sink.dart';

void main() {
  test('sessionIdShouldBeSinkId', () {
    final session = ContentWriteSession(sink: FakeByteSink(id: 'session-1'));

    expect(session.sessionId, 'session-1');
  });

  group('write', () {
    test('writeShouldPassBytesToSinkAsTheyAreIfUint8List', () async {
      final sink = FakeByteSink();
      final bytes = Uint8List.fromList([1, 2]);

      await ContentWriteSession(sink: sink).write(bytes);

      expect(sink.writes.single, same(bytes));
    });

    test('writeShouldCopyBytesIntoUint8ListIfOtherList', () async {
      final sink = FakeByteSink();

      await ContentWriteSession(sink: sink).write([1, 2]);

      expect(sink.writes.single, [1, 2]);
    });

    test('writeShouldThrowSinkErrorAndKeepSessionOpenIfWriteFails', () async {
      final sink = FakeByteSink()
        ..writeError = const NotEnoughSpaceException('full');
      final session = ContentWriteSession(sink: sink);

      await expectLater(
        session.write([1]),
        throwsA(isA<NotEnoughSpaceException>()),
      );
      expect(session.isClosed, isFalse);
    });

    test('writeShouldThrowSessionNotFoundIfSessionIsClosed', () async {
      final session = ContentWriteSession(sink: FakeByteSink(id: 'session-1'));
      await session.close();

      expect(
        session.write([1]),
        throwsA(
          isA<WriteSessionNotFoundException>().having(
            (e) => e.sessionId,
            'sessionId',
            'session-1',
          ),
        ),
      );
    });

    test('writeShouldWaitForPreviousWrite', () async {
      final sink = FakeByteSink()..writeGate = Completer<void>();
      final session = ContentWriteSession(sink: sink);

      final first = session.write([1]);
      final second = session.write([2]);
      sink.writeGate!.complete();
      await Future.wait([first, second]);

      expect(sink.writes, [
        [1],
        [2],
      ]);
    });
  });

  group('writeStream', () {
    test('writeStreamShouldWriteEveryChunkThenCloseSession', () async {
      final sink = FakeByteSink();
      final session = ContentWriteSession(sink: sink);

      await session.writeStream(
        Stream.fromIterable([
          [1, 2],
          [3],
        ]),
      );

      expect(sink.writes, [
        [1, 2],
        [3],
      ]);
      expect(sink.closeCount, 1);
      expect(session.isClosed, isTrue);
    });

    test('writeStreamShouldAbortAndRethrowIfStreamFails', () async {
      final sink = FakeByteSink();

      await expectLater(
        ContentWriteSession(
          sink: sink,
        ).writeStream(Stream.error(const FormatException('broken'))),
        throwsFormatException,
      );
      expect(sink.abortCount, 1);
      expect(sink.closeCount, 0);
    });

    test('writeStreamShouldAbortAndRethrowIfWriteFails', () async {
      final sink = FakeByteSink()..writeError = const WriteException('io');

      await expectLater(
        ContentWriteSession(sink: sink).writeStream(Stream.value([1])),
        throwsA(isA<WriteException>()),
      );
      expect(sink.abortCount, 1);
    });
  });

  group('close', () {
    test('closeShouldCloseSinkOnce', () async {
      final sink = FakeByteSink();
      final session = ContentWriteSession(sink: sink);

      await session.close();
      await session.close();

      expect(sink.closeCount, 1);
      expect(session.isClosed, isTrue);
    });

    test('closeShouldThrowSinkErrorAndLeaveSessionClosed', () async {
      final sink = FakeByteSink()
        ..closeError = const NotEnoughSpaceException('full');
      final session = ContentWriteSession(sink: sink);

      await expectLater(
        session.close(),
        throwsA(isA<NotEnoughSpaceException>()),
      );
      expect(session.isClosed, isTrue);
    });

    test('closeShouldWaitForInProgressWrite', () async {
      final sink = FakeByteSink()..writeGate = Completer<void>();
      final session = ContentWriteSession(sink: sink);

      final write = session.write([1]);
      final close = session.close();
      sink.writeGate!.complete();
      await Future.wait([write, close]);

      expect(sink.writes, [
        [1],
      ]);
      expect(sink.closeCount, 1);
    });
  });

  group('abort', () {
    test('abortShouldAbortSinkOnce', () async {
      final sink = FakeByteSink();
      final session = ContentWriteSession(sink: sink);

      await session.abort();
      await session.abort();

      expect(sink.abortCount, 1);
      expect(session.isClosed, isTrue);
    });

    test('abortShouldDoNothingIfSessionIsClosed', () async {
      final sink = FakeByteSink();
      final session = ContentWriteSession(sink: sink);
      await session.close();

      await session.abort();

      expect(sink.abortCount, 0);
    });
  });
}
