import 'dart:convert';

import 'package:content_io_android/content_io_android_method_channel.dart';
import 'package:content_io_android/src/exceptions/content_open_exception.dart';
import 'package:content_io_android/src/exceptions/content_read_exception.dart';
import 'package:content_io_android/src/io/reader/content_reader.dart';
import 'package:content_io_android/src/io/reader/content_reader_factory.dart';
import 'package:content_io_android/src/io/writer/content_writer.dart';
import 'package:content_io_android/src/io/writer/content_writer_factory.dart';
import 'package:content_io_android/src/models/content_hash.dart';
import 'package:content_io_android/src/models/content_hash_algorithm.dart';
import 'package:content_io_android/src/models/hash_content_request.dart';
import 'package:content_io_android/src/models/open_read_request.dart';
import 'package:content_io_android/src/models/open_thumbnail_read_request.dart';
import 'package:content_io_android/src/models/open_write_request.dart';
import 'package:content_io_android/src/models/thumbnail_size.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockReaderFactory extends Mock implements ContentReaderFactory {}

class _MockReader extends Mock implements ContentReader {}

class _MockWriterFactory extends Mock implements ContentWriterFactory {}

class _MockWriter extends Mock implements ContentWriter {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockReaderFactory readerFactory;
  late _MockWriterFactory writerFactory;
  late MethodChannelContentIoAndroid sut;

  setUp(() {
    readerFactory = _MockReaderFactory();
    writerFactory = _MockWriterFactory();
    sut = MethodChannelContentIoAndroid(
      readerFactory: readerFactory,
      writerFactory: writerFactory,
    );
  });

  test('openReadSessionShouldReadFromReaderFactoryOpens', () async {
    const request = OpenReadRequest(uri: 'content://media/1');
    final reader = _MockReader();
    when(() => reader.id).thenReturn('local-1');
    when(() => readerFactory.open(request)).thenAnswer((_) async => reader);

    final session = await sut.openReadSession(request);

    expect(session.sessionId, 'local-1');
  });

  test('openThumbnailReadSessionShouldReadFromReaderFactoryOpens', () async {
    const request = OpenThumbnailReadRequest(
      uri: 'content://media/1',
      size: ThumbnailSize(width: 256, height: 256),
    );
    final reader = _MockReader();
    when(() => reader.id).thenReturn('session-1');
    when(
      () => readerFactory.openThumbnail(request),
    ).thenAnswer((_) async => reader);

    final session = await sut.openThumbnailReadSession(request);

    expect(session.sessionId, 'session-1');
  });

  test('openWriteSessionShouldWriteToWriterFactoryOpens', () async {
    const request = OpenWriteRequest(uri: 'content://media/1');
    final writer = _MockWriter();
    when(() => writer.id).thenReturn('local-write-1');
    when(() => writerFactory.open(request)).thenAnswer((_) async => writer);

    final session = await sut.openWriteSession(request);

    expect(session.sessionId, 'local-write-1');
  });

  group('hashContent', () {
    const channel = MethodChannel('content_io_android');
    const request = HashContentRequest(uri: 'content://media/1');
    const hash = ContentHash(
      algorithm: ContentHashAlgorithm.sha256,
      value: '2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824',
    );
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    late List<MethodCall> calls;

    /// Makes the platform answer `hashContent` with [answer], or throw it if
    /// it's a [PlatformException].
    void replyWith(Object answer) {
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        if (answer is PlatformException) {
          throw answer;
        }
        return answer;
      });
    }

    setUp(() => calls = []);

    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    test('hashContentShouldSendRequestAsJsonToHashContent', () async {
      replyWith(jsonEncode(hash.toJson()));

      await sut.hashContent(request);

      expect(calls.single.method, 'hashContent');
      expect(jsonDecode(calls.single.arguments as String), request.toJson());
    });

    test('hashContentShouldReturnDecodedHashIfPlatformReplies', () async {
      replyWith(jsonEncode(hash.toJson()));

      expect(await sut.hashContent(request), hash);
    });

    test('hashContentShouldThrowContentOpenExceptionIfContentIsNotFound', () {
      replyWith(PlatformException(code: 'not_found'));

      expect(
        sut.hashContent(request),
        throwsA(isA<ContentNotFoundException>()),
      );
    });

    test('hashContentShouldThrowReadExceptionIfContentCanNotBeRead', () {
      replyWith(PlatformException(code: 'read_error'));

      expect(sut.hashContent(request), throwsA(isA<ReadException>()));
    });
  });
}
