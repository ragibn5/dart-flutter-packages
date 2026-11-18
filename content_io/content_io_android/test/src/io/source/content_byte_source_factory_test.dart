import 'dart:convert';
import 'dart:io';

import 'package:content_io_android/src/exceptions/content_open_exception.dart';
import 'package:content_io_android/src/io/source/channel_byte_source.dart';
import 'package:content_io_android/src/io/source/content_byte_source.dart';
import 'package:content_io_android/src/io/source/content_byte_source_factory.dart';
import 'package:content_io_android/src/io/source/descriptor_byte_source.dart';
import 'package:content_io_android/src/io/source/file_byte_source.dart';
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

/// Descriptor sources the tests opened, kept reachable: their finalizer would
/// close the descriptor through Android's libc, which the host doesn't have.
final _keptAlive = <DescriptorByteSource>[];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('test/main');
  const readChannel = MethodChannel('test/read');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late _MockMapper mapper;
  late DefaultContentByteSourceFactory sut;
  late Directory directory;

  /// The calls the platform side received, in order.
  late List<MethodCall> calls;

  /// Sources the test opened, closed in tear down.
  late List<ContentByteSource> opened;

  /// Makes the platform side answer every call with [reply] encoded as JSON.
  void replyWith(Map<String, dynamic> reply) {
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return jsonEncode(reply);
    });
  }

  Future<ContentByteSource> open(OpenReadRequest request) async {
    final source = await sut.open(request);
    if (source is DescriptorByteSource) {
      _keptAlive.add(source);
    } else {
      opened.add(source);
    }
    return source;
  }

  setUpAll(() => registerFallbackValue(PlatformException(code: 'fallback')));

  setUp(() async {
    mapper = _MockMapper();
    calls = [];
    opened = [];
    directory = await Directory.systemTemp.createTemp('source_factory');
    sut = DefaultContentByteSourceFactory(
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
    for (final source in opened) {
      await source.close();
    }
    await directory.delete(recursive: true);
  });

  group('open', () {
    test('openShouldReturnFileByteSourceIfFilePathCanBeOpened', () async {
      final path = '${directory.path}/item.bin';
      await File(path).writeAsBytes([1, 2, 3]);

      final source = await open(
        OpenReadRequest(uri: _contentUri, filePath: path),
      );

      expect(source, isA<FileByteSource>());
      expect(calls, isEmpty);
    });

    test('openShouldOpenThroughPlatformIfFilePathCanNotBeOpened', () async {
      final source = await open(
        OpenReadRequest(
          uri: _contentUri,
          filePath: '${directory.path}/missing',
        ),
      );

      expect(source, isA<ChannelByteSource>());
    });

    test('openShouldSendRequestAsJsonToOpenContentReadSession', () async {
      const request = OpenReadRequest(uri: _contentUri);

      await open(request);

      expect(calls.single.method, 'openReadSession');
      expect(jsonDecode(calls.single.arguments as String), request.toJson());
    });

    test('openShouldReturnChannelByteSourceIfPlatformRepliesChannel', () async {
      final source = await open(const OpenReadRequest(uri: _contentUri));

      expect(
        source,
        isA<ChannelByteSource>()
            .having((s) => s.id, 'id', 'session-1')
            .having((s) => s.length, 'length', 2048)
            .having((s) => s.isSeekable, 'isSeekable', isTrue),
      );
    });

    test(
      'openShouldReturnDescriptorByteSourceIfPlatformRepliesDescriptor',
      () async {
        replyWith({
          'kind': 'descriptor',
          'fd': _unusedFd,
          'offset': 0,
          'sizeInBytes': 2048,
          'isSeekable': false,
        });

        final source = await open(const OpenReadRequest(uri: _contentUri));

        expect(
          source,
          isA<DescriptorByteSource>()
              .having((s) => s.length, 'length', 2048)
              .having((s) => s.isSeekable, 'isSeekable', isFalse),
        );
      },
    );

    test('openShouldGiveEachLocalSourceItsOwnId', () async {
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
