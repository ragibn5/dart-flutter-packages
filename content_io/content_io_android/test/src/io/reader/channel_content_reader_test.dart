import 'dart:convert';
import 'dart:math';

import 'package:content_io_android/src/exceptions/content_read_exception.dart';
import 'package:content_io_android/src/io/reader/channel_content_reader.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMapper extends Mock implements ContentReadExceptionMapper {}

class _MappedException implements Exception {
  const _MappedException();
}

/// The most bytes the reader asks for in one call.
const _maxBytesPerCall = 512 * 1024;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('test/main');
  const readChannel = MethodChannel('test/read');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late _MockMapper mapper;

  /// The decoded `readFromSession` requests, in order.
  late List<Map<String, dynamic>> readRequests;

  /// The calls on the main channel, in order.
  late List<MethodCall> mainCalls;

  /// Serves reads of an item of [itemLength] bytes, each byte its own offset
  /// modulo 256.
  void serveItem(int itemLength) {
    messenger.setMockMethodCallHandler(readChannel, (call) async {
      final request =
          jsonDecode(call.arguments as String) as Map<String, dynamic>;
      readRequests.add(request);
      final start = request['start'] as int;
      final end = min(start + (request['length'] as int), itemLength);
      return Uint8List.fromList([for (var i = start; i < end; i++) i % 256]);
    });
  }

  ChannelContentReader createSource({bool isSeekable = true}) {
    return ChannelContentReader(
      channel: channel,
      readChannel: readChannel,
      id: 'session-1',
      length: null,
      isSeekable: isSeekable,
      exceptionMapper: mapper,
    );
  }

  setUpAll(() => registerFallbackValue(PlatformException(code: 'fallback')));

  setUp(() {
    mapper = _MockMapper();
    readRequests = [];
    mainCalls = [];
    messenger.setMockMethodCallHandler(channel, (call) async {
      mainCalls.add(call);
      return null;
    });
  });

  tearDown(() {
    messenger
      ..setMockMethodCallHandler(channel, null)
      ..setMockMethodCallHandler(readChannel, null);
  });

  group('read', () {
    test('readShouldSendSessionIdStartAndLengthToReadFromSession', () async {
      serveItem(10);

      await createSource().read(4);

      expect(readRequests.single, {
        'sessionId': 'session-1',
        'start': 0,
        'length': 4,
      });
    });

    test('readShouldStartWhereThePreviousReadEnded', () async {
      serveItem(10);
      final reader = createSource();

      await reader.read(4);
      expect(await reader.read(2), [4, 5]);
    });

    test('readShouldStartAtPositionIfPositionIsGiven', () async {
      serveItem(10);

      expect(await createSource().read(2, position: 6), [6, 7]);
    });

    test(
      'readShouldSplitIntoSeveralCallsIfMaxLengthExceedsCallLimit',
      () async {
        serveItem(_maxBytesPerCall + 10);

        final bytes = await createSource().read(_maxBytesPerCall + 10);

        expect(bytes, hasLength(_maxBytesPerCall + 10));
        expect(readRequests.map((r) => r['length']), [_maxBytesPerCall, 10]);
      },
    );

    test('readShouldReturnFewerBytesIfItemEndsFirst', () async {
      serveItem(3);

      expect(await createSource().read(8), [0, 1, 2]);
    });

    test('readShouldThrowRangeErrorIfPositionIsNegative', () {
      expect(createSource().read(2, position: -1), throwsRangeError);
    });

    test('readShouldThrowUnsupportedErrorIfPositionIsGivenToUnseekable', () {
      expect(
        createSource(isSeekable: false).read(2, position: 1),
        throwsUnsupportedError,
      );
    });

    test('readShouldThrowMappedExceptionIfPlatformFails', () {
      when(() => mapper.map(any())).thenReturn(const _MappedException());
      messenger.setMockMethodCallHandler(
        readChannel,
        (_) async => throw PlatformException(code: 'read_error'),
      );

      expect(createSource().read(2), throwsA(isA<_MappedException>()));
    });
  });

  group('readAll', () {
    test(
      'readAllShouldReadToEndFromCurrentPositionIfPositionIsNotGiven',
      () async {
        serveItem(6);
        final reader = createSource();
        await reader.read(2);

        expect(await reader.readAll(), [2, 3, 4, 5]);
      },
    );

    test('readAllShouldReadToEndFromPositionIfPositionIsGiven', () async {
      serveItem(6);

      expect(await createSource().readAll(position: 4), [4, 5]);
    });
  });

  group('close', () {
    test('closeShouldSendSessionIdToCloseReadSession', () async {
      await createSource().close();

      expect(mainCalls.single.method, 'closeReadSession');
      expect(mainCalls.single.arguments, {'sessionId': 'session-1'});
    });

    test('closeShouldNotThrowIfPlatformFails', () async {
      messenger.setMockMethodCallHandler(
        channel,
        (_) async => throw PlatformException(code: 'unexpected'),
      );

      await expectLater(createSource().close(), completes);
    });
  });
}
