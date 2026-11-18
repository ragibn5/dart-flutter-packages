import 'package:content_io_android/src/exceptions/content_write_exception.dart';
import 'package:content_io_android/src/io/writer/channel_content_writer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMapper extends Mock implements ContentWriteExceptionMapper {}

class _MappedException implements Exception {
  const _MappedException();
}

/// The most bytes the writer sends in one call.
const _maxBytesPerCall = 512 * 1024;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const writeChannel = MethodChannel('test/write');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late _MockMapper mapper;
  late ChannelContentWriter sut;

  /// The calls the platform side received, in order.
  late List<MethodCall> calls;

  /// Makes the platform side record every call, and fail it with [error]
  /// when given.
  void serve({PlatformException? error}) {
    messenger.setMockMethodCallHandler(writeChannel, (call) async {
      calls.add(call);
      if (error != null) {
        throw error;
      }
      return null;
    });
  }

  setUpAll(() => registerFallbackValue(PlatformException(code: 'fallback')));

  setUp(() {
    mapper = _MockMapper();
    calls = [];
    sut = ChannelContentWriter(
      writeChannel: writeChannel,
      id: 'session-1',
      exceptionMapper: mapper,
    );
  });

  tearDown(() => messenger.setMockMethodCallHandler(writeChannel, null));

  test('writeShouldSendBytesWithSessionIdToWriteToSession', () async {
    serve();

    await sut.write(Uint8List.fromList([1, 2, 3]));

    expect(calls.single.method, 'writeToSession');
    expect(calls.single.arguments, {
      'sessionId': 'session-1',
      'bytes': [1, 2, 3],
    });
  });

  test('writeShouldSplitBytesIntoCallsOfAtMostMaxBytesPerCall', () async {
    serve();
    final bytes = Uint8List.fromList(
      List.generate(_maxBytesPerCall + 1, (i) => i % 256),
    );

    await sut.write(bytes);

    final sent = [
      for (final call in calls)
        (call.arguments as Map<Object?, Object?>)['bytes']! as Uint8List,
    ];
    expect(sent.map((e) => e.length), [_maxBytesPerCall, 1]);
    expect(sent.expand((e) => e), bytes);
  });

  test('writeShouldSendNothingIfBytesAreEmpty', () async {
    serve();

    await sut.write(Uint8List(0));

    expect(calls, isEmpty);
  });

  test('writeShouldThrowMappedExceptionIfPlatformFails', () {
    when(() => mapper.map(any())).thenReturn(const _MappedException());
    serve(error: PlatformException(code: 'write_error'));

    expect(
      sut.write(Uint8List.fromList([1])),
      throwsA(isA<_MappedException>()),
    );
  });

  test('closeShouldSendSessionIdToCloseWriteSession', () async {
    serve();

    await sut.close();

    expect(calls.single.method, 'closeWriteSession');
    expect(calls.single.arguments, {'sessionId': 'session-1'});
  });

  test('closeShouldThrowMappedExceptionIfPlatformFails', () {
    when(() => mapper.map(any())).thenReturn(const _MappedException());
    serve(error: PlatformException(code: 'not_enough_space'));

    expect(sut.close(), throwsA(isA<_MappedException>()));
  });

  test('abortShouldSendSessionIdToAbortWriteSession', () async {
    serve();

    await sut.abort();

    expect(calls.single.method, 'abortWriteSession');
    expect(calls.single.arguments, {'sessionId': 'session-1'});
  });

  test('abortShouldNotThrowIfPlatformFails', () async {
    serve(error: PlatformException(code: 'unexpected_error'));

    await expectLater(sut.abort(), completes);
  });
}
