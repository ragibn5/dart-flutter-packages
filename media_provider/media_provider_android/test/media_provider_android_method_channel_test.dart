import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/media_provider_android_method_channel.dart';
import 'package:media_provider_android/src/exceptions/media_action_exception.dart';
import 'package:media_provider_android/src/exceptions/media_query_exception.dart';
import 'package:media_provider_android/src/models/media_type.dart';
import 'package:media_provider_android/src/models/open_media_with_request.dart';
import 'package:media_provider_android/src/models/query_spec.dart';
import 'package:media_provider_android/src/models/share_media_request.dart';
import 'package:media_provider_android/src/models/volume_info.dart';
import 'package:media_provider_android/src/models/volume_spec.dart';
import 'package:media_provider_android/src/models/volume_state.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/fixtures.dart';

class _MockQueryMapper extends Mock implements MediaQueryExceptionMapper {}

class _MockActionMapper extends Mock implements MediaActionExceptionMapper {}

class _MappedException implements Exception {
  const _MappedException();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(MethodChannelMediaProviderAndroid.CHANNEL_NAME);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late _MockQueryMapper queryMapper;
  late _MockActionMapper actionMapper;
  late MethodChannelMediaProviderAndroid sut;

  /// The calls the platform side received, in order.
  late List<MethodCall> calls;

  /// Makes the platform side answer every call with [reply], or throw it when
  /// it's a [PlatformException].
  void replyWith(Object? reply) {
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (reply is PlatformException) {
        throw reply;
      }
      return reply;
    });
  }

  setUpAll(() {
    registerFallbackValue(PlatformException(code: 'fallback'));
  });

  setUp(() {
    queryMapper = _MockQueryMapper();
    actionMapper = _MockActionMapper();
    calls = [];
    sut = MethodChannelMediaProviderAndroid(
      queryMediaExceptionMapper: queryMapper,
      mediaActionExceptionMapper: actionMapper,
    );
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  group('getVolumes', () {
    test('getVolumesShouldReturnDecodedVolumesIfPlatformReplies', () async {
      replyWith(
        jsonEncode([
          {
            'identity': primaryVolumeIdentityJson,
            'state': 'MOUNTED',
            'availableSpaceInBytes': 64000000000,
            'documentsRootUri': primaryRootUri,
          },
        ]),
      );

      final volumes = await sut.getVolumes();

      expect(calls.single.method, 'getVolumes');
      expect(volumes, const [
        VolumeInfo(
          identity: primaryVolumeIdentity,
          state: VolumeState.mounted,
          availableSpaceInBytes: 64000000000,
          documentsRootUri: primaryRootUri,
        ),
      ]);
    });
  });

  group('getMedia', () {
    final query = QuerySpec(
      types: const {MediaType.photo},
      volumes: {const PrimaryVolumeSpec()},
    );

    test('getMediaShouldSendQueryAsJsonToQueryMedia', () async {
      replyWith('[]');

      await sut.getMedia(query);

      expect(calls.single.method, 'queryMedia');
      expect(jsonDecode(calls.single.arguments as String), query.toJson());
    });

    test('getMediaShouldReturnDecodedItemsIfPlatformReplies', () async {
      replyWith(jsonEncode([photoItemJson]));

      expect(await sut.getMedia(query), [photoItem]);
    });

    test('getMediaShouldThrowMappedExceptionIfPlatformFails', () {
      when(() => queryMapper.map(any())).thenReturn(const _MappedException());
      replyWith(PlatformException(code: 'invalid_request'));

      expect(sut.getMedia(query), throwsA(isA<_MappedException>()));
    });
  });

  group('shareMedia', () {
    final request = ShareMediaRequest(
      contentUris: const ['content://media/1'],
      chooserTitle: 'Share',
    );

    test('shareMediaShouldSendRequestAsJsonToShareMedia', () async {
      replyWith(null);

      await sut.shareMedia(request);

      expect(calls.single.method, 'shareMedia');
      expect(jsonDecode(calls.single.arguments as String), request.toJson());
    });

    test('shareMediaShouldThrowMappedExceptionIfPlatformFails', () {
      when(() => actionMapper.map(any())).thenReturn(const _MappedException());
      replyWith(PlatformException(code: 'no_activity'));

      expect(sut.shareMedia(request), throwsA(isA<_MappedException>()));
    });
  });

  group('openMediaWith', () {
    const request = OpenMediaWithRequest(
      contentUri: 'content://media/1',
      chooserTitle: 'Open with',
    );

    test('openMediaWithShouldSendRequestAsJsonToOpenMediaWith', () async {
      replyWith(null);

      await sut.openMediaWith(request);

      expect(calls.single.method, 'openMediaWith');
      expect(jsonDecode(calls.single.arguments as String), request.toJson());
    });

    test('openMediaWithShouldThrowMappedExceptionIfPlatformFails', () {
      when(() => actionMapper.map(any())).thenReturn(const _MappedException());
      replyWith(PlatformException(code: 'no_activity'));

      expect(sut.openMediaWith(request), throwsA(isA<_MappedException>()));
    });
  });
}
