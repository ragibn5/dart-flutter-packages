import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/media_provider_android_method_channel.dart';
import 'package:media_provider_android/media_provider_android_platform_interface.dart';
import 'package:media_provider_android/src/models/open_media_read_request.dart';
import 'package:media_provider_android/src/models/open_media_with_request.dart';
import 'package:media_provider_android/src/models/open_thumbnail_read_request.dart';
import 'package:media_provider_android/src/models/query_spec.dart';
import 'package:media_provider_android/src/models/share_media_request.dart';
import 'package:media_provider_android/src/models/thumbnail_size.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Extends the platform interface without overriding anything.
class _BarePlatform extends MediaProviderAndroidPlatform {}

/// Implements the platform interface without its token.
class _TokenlessPlatform implements MediaProviderAndroidPlatform {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Implements the platform interface the way test mocks do.
class _MockPlatform
    with MockPlatformInterfaceMixin
    implements MediaProviderAndroidPlatform {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final platform = _BarePlatform();

  group('instance', () {
    late MediaProviderAndroidPlatform original;

    setUp(() => original = MediaProviderAndroidPlatform.instance);

    tearDown(() => MediaProviderAndroidPlatform.instance = original);

    test('instanceShouldBeMethodChannelImplementationByDefault', () {
      expect(
        MediaProviderAndroidPlatform.instance,
        isA<MethodChannelMediaProviderAndroid>(),
      );
    });

    test('instanceShouldBeReplacedIfSetToImplementationWithToken', () {
      final mock = _MockPlatform();

      MediaProviderAndroidPlatform.instance = mock;

      expect(MediaProviderAndroidPlatform.instance, same(mock));
    });

    test('instanceShouldThrowAssertionErrorIfSetWithoutToken', () {
      expect(
        () => MediaProviderAndroidPlatform.instance = _TokenlessPlatform(),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  test('getVolumesShouldThrowUnimplementedErrorIfNotOverridden', () {
    expect(platform.getVolumes, throwsUnimplementedError);
  });

  test('getMediaShouldThrowUnimplementedErrorIfNotOverridden', () {
    expect(
      () => platform.getMedia(const QuerySpec(types: {}, volumes: {})),
      throwsUnimplementedError,
    );
  });

  test('openReadSessionShouldThrowUnimplementedErrorIfNotOverridden', () {
    expect(
      () => platform.openReadSession(
        const OpenMediaReadRequest(contentUri: 'content://media/1'),
      ),
      throwsUnimplementedError,
    );
  });

  test(
    'openThumbnailReadSessionShouldThrowUnimplementedErrorIfNotOverridden',
    () {
      expect(
        () => platform.openThumbnailReadSession(
          const OpenThumbnailReadRequest(
            contentUri: 'content://media/1',
            size: ThumbnailSize(width: 256, height: 256),
          ),
        ),
        throwsUnimplementedError,
      );
    },
  );

  test('shareMediaShouldThrowUnimplementedErrorIfNotOverridden', () {
    expect(
      () => platform.shareMedia(
        ShareMediaRequest(contentUris: const ['content://media/1']),
      ),
      throwsUnimplementedError,
    );
  });

  test('openMediaWithShouldThrowUnimplementedErrorIfNotOverridden', () {
    expect(
      () => platform.openMediaWith(
        const OpenMediaWithRequest(contentUri: 'content://media/1'),
      ),
      throwsUnimplementedError,
    );
  });
}
