import 'dart:convert';
import 'dart:io';

import 'package:content_io_android/src/exceptions/content_open_exception.dart';
import 'package:content_io_android/src/io/reader/channel_content_reader.dart';
import 'package:content_io_android/src/io/reader/content_reader.dart';
import 'package:content_io_android/src/io/reader/content_reader_factory.dart';
import 'package:content_io_android/src/io/reader/descriptor_content_reader.dart';
import 'package:content_io_android/src/io/reader/file_content_reader.dart';
import 'package:content_io_android/src/models/open_read_request.dart';
import 'package:content_io_android/src/models/open_thumbnail_read_request.dart';
import 'package:content_io_android/src/models/thumbnail_size.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMapper extends Mock implements ContentOpenExceptionMapper {}

class _MappedException implements Exception {
  const _MappedException();
}

/// A descriptor number no test process has open, so a stray close is harmless.
const _unusedFd = 987654;

const _contentUri = 'content://media/external/images/media/1';

/// Descriptor readers the tests opened, kept reachable: their finalizer would
/// close the descriptor through Android's libc, which the host doesn't have.
final _keptAlive = <DescriptorContentReader>[];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('test/main');
  const readChannel = MethodChannel('test/read');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late _MockMapper mapper;
  late DefaultContentReaderFactory sut;
  late Directory directory;

  /// The calls the platform side received, in order.
  late List<MethodCall> calls;

  /// Readers the test opened, closed in tear down.
  late List<ContentReader> opened;

  /// Makes the platform side answer every call with [reply] encoded as JSON.
  void replyWith(Map<String, dynamic> reply) {
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return jsonEncode(reply);
    });
  }

  Future<ContentReader> open(OpenReadRequest request) async {
    final reader = await sut.open(request);
    if (reader is DescriptorContentReader) {
      _keptAlive.add(reader);
    } else {
      opened.add(reader);
    }
    return reader;
  }

  setUpAll(() => registerFallbackValue(PlatformException(code: 'fallback')));

  setUp(() async {
    mapper = _MockMapper();
    calls = [];
    opened = [];
    directory = await Directory.systemTemp.createTemp('source_factory');
    sut = DefaultContentReaderFactory(
      channel: channel,
      readChannel: readChannel,
      exceptionMapper: mapper,
    );
    replyWith({
      'kind': 'channel',
      'sessionId': 'session-1',
      'sizeInBytes': 2048,
      'isSeekable': true,
    });
  });

  tearDown(() async {
    messenger.setMockMethodCallHandler(channel, null);
    for (final reader in opened) {
      await reader.close();
    }
    await directory.delete(recursive: true);
  });

  group('open', () {
    test('openShouldReturnFileContentReaderIfFilePathCanBeOpened', () async {
      final path = '${directory.path}/item.bin';
      await File(path).writeAsBytes([1, 2, 3]);

      final reader = await open(
        OpenReadRequest(uri: _contentUri, filePath: path),
      );

      expect(reader, isA<FileContentReader>());
      expect(calls, isEmpty);
    });

    test('openShouldOpenThroughPlatformIfFilePathCanNotBeOpened', () async {
      final reader = await open(
        OpenReadRequest(
          uri: _contentUri,
          filePath: '${directory.path}/missing',
        ),
      );

      expect(reader, isA<ChannelContentReader>());
    });

    test('openShouldSendRequestAsJsonToOpenContentReadSession', () async {
      const request = OpenReadRequest(uri: _contentUri);

      await open(request);

      expect(calls.single.method, 'openReadSession');
      expect(jsonDecode(calls.single.arguments as String), request.toJson());
    });

    test(
      'openShouldReturnChannelContentReaderIfPlatformRepliesChannel',
      () async {
        final reader = await open(const OpenReadRequest(uri: _contentUri));

        expect(
          reader,
          isA<ChannelContentReader>()
              .having((s) => s.id, 'id', 'session-1')
              .having((s) => s.length, 'length', 2048)
              .having((s) => s.isSeekable, 'isSeekable', isTrue),
        );
      },
    );

    test(
      'openShouldReturnDescriptorContentReaderIfPlatformRepliesDescriptor',
      () async {
        replyWith({
          'kind': 'descriptor',
          'fd': _unusedFd,
          'offset': 0,
          'sizeInBytes': 2048,
          'isSeekable': false,
        });

        final reader = await open(const OpenReadRequest(uri: _contentUri));

        expect(
          reader,
          isA<DescriptorContentReader>()
              .having((s) => s.length, 'length', 2048)
              .having((s) => s.isSeekable, 'isSeekable', isFalse),
        );
      },
    );

    test('openShouldGiveEachLocalReaderItsOwnId', () async {
      final path = '${directory.path}/item.bin';
      await File(path).writeAsBytes([1, 2, 3]);
      final request = OpenReadRequest(uri: _contentUri, filePath: path);

      final first = await open(request);
      final second = await open(request);

      expect(first.id, isNot(second.id));
    });

    test('openShouldThrowMappedExceptionIfPlatformFails', () {
      when(() => mapper.map(any())).thenReturn(const _MappedException());
      messenger.setMockMethodCallHandler(
        channel,
        (_) async => throw PlatformException(code: 'not_found'),
      );

      expect(
        sut.open(const OpenReadRequest(uri: _contentUri)),
        throwsA(isA<_MappedException>()),
      );
    });
  });

  group('openThumbnail', () {
    test(
      'openThumbnailShouldSendRequestAsJsonToOpenThumbnailReadSession',
      () async {
        const request = OpenThumbnailReadRequest(
          uri: _contentUri,
          size: ThumbnailSize(width: 256, height: 256),
        );

        opened.add(await sut.openThumbnail(request));

        expect(calls.single.method, 'openThumbnailReadSession');
        expect(jsonDecode(calls.single.arguments as String), request.toJson());
      },
    );
  });
}
