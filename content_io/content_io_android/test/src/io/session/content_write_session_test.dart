import 'dart:async';
import 'dart:typed_data';

import 'package:content_io_android/src/exceptions/content_write_exception.dart';
import 'package:content_io_android/src/io/session/content_write_session.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_content_writer.dart';

void main() {
  test('sessionIdShouldBeWriterId', () {
    final session = ContentWriteSession(
      writer: FakeContentWriter(id: 'session-1'),
    );

    expect(session.sessionId, 'session-1');
  });

  group('write', () {
    test('writeShouldPassBytesToWriterAsTheyAreIfUint8List', () async {
      final writer = FakeContentWriter();
      final bytes = Uint8List.fromList([1, 2]);

      await ContentWriteSession(writer: writer).write(bytes);

      expect(writer.writes.single, same(bytes));
    });

    test('writeShouldCopyBytesIntoUint8ListIfOtherList', () async {
      final writer = FakeContentWriter();

      await ContentWriteSession(writer: writer).write([1, 2]);

      expect(writer.writes.single, [1, 2]);
    });

    test('writeShouldThrowWriterErrorAndKeepSessionOpenIfWriteFails', () async {
      final writer = FakeContentWriter()
        ..writeError = const NotEnoughSpaceException('full');
      final session = ContentWriteSession(writer: writer);

      await expectLater(
        session.write([1]),
        throwsA(isA<NotEnoughSpaceException>()),
      );
      expect(session.isClosed, isFalse);
    });

    test('writeShouldThrowSessionNotFoundIfSessionIsClosed', () async {
      final session = ContentWriteSession(
        writer: FakeContentWriter(id: 'session-1'),
      );
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
      final writer = FakeContentWriter()..writeGate = Completer<void>();
      final session = ContentWriteSession(writer: writer);

      final first = session.write([1]);
      final second = session.write([2]);
      writer.writeGate!.complete();
      await Future.wait([first, second]);

      expect(writer.writes, [
        [1],
        [2],
      ]);
    });
  });

  group('writeStream', () {
    test('writeStreamShouldWriteEveryChunkThenCloseSession', () async {
      final writer = FakeContentWriter();
      final session = ContentWriteSession(writer: writer);

      await session.writeStream(
        Stream.fromIterable([
          [1, 2],
          [3],
        ]),
      );

      expect(writer.writes, [
        [1, 2],
        [3],
      ]);
      expect(writer.closeCount, 1);
      expect(session.isClosed, isTrue);
    });

    test('writeStreamShouldAbortAndRethrowIfStreamFails', () async {
      final writer = FakeContentWriter();

      await expectLater(
        ContentWriteSession(
          writer: writer,
        ).writeStream(Stream.error(const FormatException('broken'))),
        throwsFormatException,
      );
      expect(writer.abortCount, 1);
      expect(writer.closeCount, 0);
    });

    test('writeStreamShouldAbortAndRethrowIfWriteFails', () async {
      final writer = FakeContentWriter()
        ..writeError = const WriteException('io');

      await expectLater(
        ContentWriteSession(writer: writer).writeStream(Stream.value([1])),
        throwsA(isA<WriteException>()),
      );
      expect(writer.abortCount, 1);
    });
  });

  group('close', () {
    test('closeShouldCloseWriterOnce', () async {
      final writer = FakeContentWriter();
      final session = ContentWriteSession(writer: writer);

      await session.close();
      await session.close();

      expect(writer.closeCount, 1);
      expect(session.isClosed, isTrue);
    });

    test('closeShouldThrowWriterErrorAndLeaveSessionClosed', () async {
      final writer = FakeContentWriter()
        ..closeError = const NotEnoughSpaceException('full');
      final session = ContentWriteSession(writer: writer);

      await expectLater(
        session.close(),
        throwsA(isA<NotEnoughSpaceException>()),
      );
      expect(session.isClosed, isTrue);
    });

    test('closeShouldWaitForInProgressWrite', () async {
      final writer = FakeContentWriter()..writeGate = Completer<void>();
      final session = ContentWriteSession(writer: writer);

      final write = session.write([1]);
      final close = session.close();
      writer.writeGate!.complete();
      await Future.wait([write, close]);

      expect(writer.writes, [
        [1],
      ]);
      expect(writer.closeCount, 1);
    });
  });

  group('abort', () {
    test('abortShouldAbortWriterOnce', () async {
      final writer = FakeContentWriter();
      final session = ContentWriteSession(writer: writer);

      await session.abort();
      await session.abort();

      expect(writer.abortCount, 1);
      expect(session.isClosed, isTrue);
    });

    test('abortShouldDoNothingIfSessionIsClosed', () async {
      final writer = FakeContentWriter();
      final session = ContentWriteSession(writer: writer);
      await session.close();

      await session.abort();

      expect(writer.abortCount, 0);
    });
  });
}
