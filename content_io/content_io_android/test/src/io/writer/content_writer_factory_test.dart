import 'dart:convert';

import 'package:content_io_android/src/exceptions/content_open_exception.dart';
import 'package:content_io_android/src/io/writer/channel_content_writer.dart';
import 'package:content_io_android/src/io/writer/content_writer_factory.dart';
import 'package:content_io_android/src/io/writer/descriptor_content_writer.dart';
import 'package:content_io_android/src/models/open_write_request.dart';
import 'package:content_io_android/src/models/write_mode.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMapper extends Mock implements ContentOpenExceptionMapper {}

class _MappedException implements Exception {
  const _MappedException();
}

/// A descriptor number no test process has open, so a stray close is harmless.
const _unusedFd = 987654;

const _request = OpenWriteRequest(
  uri: 'content://com.android.externalstorage.documents/document/1',
  mode: WriteMode.append,
);

/// Descriptor writers the tests opened, kept reachable: their finalizer would
/// close the descriptor through Android's libc, which the host doesn't have.
final _keptAlive = <DescriptorContentWriter>[];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('test/main');
  const writeChannel = MethodChannel('test/write');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late _MockMapper mapper;
  late DefaultContentWriterFactory sut;

  /// The calls the platform side received, in order.
  late List<MethodCall> calls;

  /// Makes the platform side answer every call with [reply], encoded as JSON
  /// when it's a map, or throw it when it's a [PlatformException].
  void replyWith(Object reply) {
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (reply is PlatformException) {
        throw reply;
      }
      return jsonEncode(reply);
    });
  }

  setUpAll(() => registerFallbackValue(PlatformException(code: 'fallback')));

  setUp(() {
    mapper = _MockMapper();
    calls = [];
    sut = DefaultContentWriterFactory(
      channel: channel,
      writeChannel: writeChannel,
      exceptionMapper: mapper,
    );
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('openShouldSendRequestAsJsonToOpenWriteSession', () async {
    replyWith(const {'kind': 'channel', 'sessionId': 'session-1'});

    await sut.open(_request);

    expect(calls.single.method, 'openWriteSession');
    expect(jsonDecode(calls.single.arguments as String), _request.toJson());
  });

  test(
    'openShouldReturnDescriptorWriterWithLocalIdIfReplyIsDescriptor',
    () async {
      replyWith(const {'kind': 'descriptor', 'fd': _unusedFd});

      final writer = await sut.open(_request);
      if (writer is DescriptorContentWriter) {
        _keptAlive.add(writer);
      }

      expect(
        writer,
        isA<DescriptorContentWriter>().having(
          (e) => e.id,
          'id',
          startsWith('local-write-'),
        ),
      );
    },
  );

  test('openShouldReturnChannelWriterWithSessionIdIfReplyIsChannel', () async {
    replyWith(const {'kind': 'channel', 'sessionId': 'session-1'});

    expect(
      await sut.open(_request),
      isA<ChannelContentWriter>().having((e) => e.id, 'id', 'session-1'),
    );
  });

  test('openShouldThrowMappedExceptionIfPlatformFails', () {
    when(() => mapper.map(any())).thenReturn(const _MappedException());
    replyWith(PlatformException(code: 'not_found'));

    expect(sut.open(_request), throwsA(isA<_MappedException>()));
  });
}
