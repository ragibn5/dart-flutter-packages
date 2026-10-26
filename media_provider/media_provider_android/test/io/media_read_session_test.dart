import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/src/exceptions/media_read_exception.dart';
import 'package:media_provider_android/src/io/session/media_read_session.dart';
import 'package:media_provider_android/src/io/source/channel_byte_source.dart';
import 'package:media_provider_android/src/io/source/file_byte_source.dart';
import 'package:media_provider_android/src/io/source/media_byte_source_factory.dart';
import 'package:media_provider_android/src/models/open_media_read_request.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late File file;
  final content = Uint8List.fromList(List.generate(10000, (i) => i % 251));

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('media_read_test');
    file = File('${directory.path}/item.bin');
    await file.writeAsBytes(content);
  });

  tearDown(() => directory.delete(recursive: true));

  Future<MediaReadSession> openSession() async {
    final source = await FileByteSource.open(id: 'local-1', path: file.path);
    return MediaReadSession(source: source);
  }

  group('MediaReadSession', () {
    test('reports the source id and size', () async {
      final session = await openSession();
      addTearDown(session.close);

      expect(session.sessionId, 'local-1');
      expect(session.sizeInBytes, content.length);
      expect(session.isClosed, isFalse);
    });

    test('openRead streams the whole item in chunks, then closes', () async {
      final session = await openSession();

      final chunks = await session.openRead(chunkSize: 4096).toList();

      expect(chunks.map((it) => it.length), [4096, 4096, 1808]);
      expect(chunks.expand((it) => it).toList(), content);
      expect(session.isClosed, isTrue);
    });

    test('readAsBytes reads the whole item, then closes', () async {
      final session = await openSession();

      expect(await session.readAsBytes(), content);
      expect(session.isClosed, isTrue);
    });

    test('cancelling the stream closes the session', () async {
      final session = await openSession();
      final closed = Completer<void>();

      late StreamSubscription<Uint8List> subscription;
      subscription = session.openRead(chunkSize: 100).listen((_) async {
        await subscription.cancel();
        closed.complete();
      });
      await closed.future;

      expect(session.isClosed, isTrue);
    });

    test('a session can be read only once', () async {
      final session = await openSession();
      await session.readAsBytes();

      expect(session.openRead, throwsStateError);
      expect(session.readAsBytes(), throwsStateError);
    });

    test('rejects a non-positive chunk size', () async {
      final session = await openSession();
      addTearDown(session.close);

      expect(() => session.openRead(chunkSize: 0), throwsRangeError);
    });

    test('reading after close fails with SessionNotFoundException', () async {
      final session = await openSession();
      await session.close();

      expect(
        session.openRead().toList(),
        throwsA(isA<SessionNotFoundException>()),
      );
    });

    test('close is idempotent', () async {
      final session = await openSession();

      await session.close();
      await session.close();

      expect(session.isClosed, isTrue);
    });
  });

  group('FileByteSource', () {
    late FileByteSource source;

    setUp(() async {
      source = await FileByteSource.open(id: 'local-1', path: file.path);
    });

    tearDown(() => source.close());

    test('reads in order from where the previous read ended', () async {
      expect(await source.read(10), content.sublist(0, 10));
      expect(await source.read(10), content.sublist(10, 20));
    });

    test('a read with a position continues from there', () async {
      expect(await source.read(10, position: 500), content.sublist(500, 510));
      expect(await source.read(10), content.sublist(510, 520));
    });

    test('readAll reads from the position to the end', () async {
      expect(await source.readAll(position: 9000), content.sublist(9000));
      expect(await source.read(10), isEmpty);
    });

    test('rejects a negative position', () {
      expect(source.read(10, position: -1), throwsRangeError);
    });

    test('open fails with FileSystemException for a missing file', () {
      expect(
        FileByteSource.open(id: 'local-2', path: '${directory.path}/missing'),
        throwsA(isA<FileSystemException>()),
      );
    });
  });

  group('DefaultMediaByteSourceFactory', () {
    const channel = MethodChannel('test/main');
    const readChannel = MethodChannel('test/read');
    const factory = DefaultMediaByteSourceFactory(
      channel: channel,
      readChannel: readChannel,
    );
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final calls = <MethodCall>[];

    void replyToOpen(Map<String, Object?> reply) {
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return call.method == 'openMediaReadSession' ? jsonEncode(reply) : null;
      });
    }

    setUp(calls.clear);

    tearDown(() {
      messenger
        ..setMockMethodCallHandler(channel, null)
        ..setMockMethodCallHandler(readChannel, null);
    });

    test('opens a readable path without a platform call', () async {
      replyToOpen({});

      final source = await factory.open(
        OpenMediaReadRequest(contentUri: 'content://x/1', filePath: file.path),
      );
      addTearDown(source.close);

      expect(source, isA<FileByteSource>());
      expect(calls, isEmpty);
    });

    test('falls back to the platform when the path is unreadable', () async {
      replyToOpen({
        'kind': 'channel',
        'sessionId': 's1',
        'sizeInBytes': 3,
        'isSeekable': true,
      });
      messenger.setMockMethodCallHandler(readChannel, (call) async {
        final request =
            jsonDecode(call.arguments as String) as Map<String, dynamic>;
        final start = request['start'] as int;
        return Uint8List.fromList([1, 2, 3].skip(start).toList());
      });

      final source = await factory.open(
        OpenMediaReadRequest(
          contentUri: 'content://x/1',
          filePath: '${directory.path}/missing',
        ),
      );

      expect(source, isA<ChannelByteSource>());
      expect(source.id, 's1');
      expect(await source.readAll(), [1, 2, 3]);

      await source.close();
      expect(calls.map((it) => it.method), [
        'openMediaReadSession',
        'closeReadSession',
      ]);
      expect(calls.last.arguments, {'sessionId': 's1'});
    });

    test('rejects a reply of an unknown kind', () {
      replyToOpen({'kind': 'pipe'});

      expect(
        factory.open(const OpenMediaReadRequest(contentUri: 'content://x/1')),
        throwsFormatException,
      );
    });
  });
}
