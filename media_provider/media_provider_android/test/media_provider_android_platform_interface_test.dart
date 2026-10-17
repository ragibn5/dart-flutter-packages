import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/media_provider_android.dart';
import 'package:media_provider_android/media_provider_android_method_channel.dart';
import 'package:media_provider_android/media_provider_android_platform_interface.dart';

/// A platform implementation that extends the interface correctly, as the
/// `plugin_platform_interface` contract requires.
class _ExtendingPlatform extends MediaProviderAndroidPlatform {}

void main() {
  late MediaProviderAndroidPlatform initialInstance;

  setUp(() {
    initialInstance = MediaProviderAndroidPlatform.instance;
  });

  tearDown(() {
    MediaProviderAndroidPlatform.instance = initialInstance;
  });

  group('instance', () {
    test('defaults to the method channel implementation', () {
      expect(
        MediaProviderAndroidPlatform.instance,
        isA<MethodChannelMediaProviderAndroid>(),
      );
    });

    test('throws when set to an implementation that breaks the token', () {
      expect(
        () => MediaProviderAndroidPlatform.instance = _BrokenPlatform(),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('getMedia', () {
    test('throws UnimplementedError by default', () {
      final sut = _ExtendingPlatform();

      expect(
        () => sut.getMedia(const QuerySpec(types: {}, volumes: {})),
        throwsA(
          isA<UnimplementedError>().having(
            (error) => error.message,
            'message',
            'getMedia() has not been implemented.',
          ),
        ),
      );
    });
  });

  group('getVolumes', () {
    test('throws UnimplementedError by default', () {
      final sut = _ExtendingPlatform();

      expect(
        sut.getVolumes,
        throwsA(
          // The message names the method that is missing, so a copy-paste
          // slip between the two members is caught here.
          isA<UnimplementedError>().having(
            (error) => error.message,
            'message',
            'getVolumes() has not been implemented.',
          ),
        ),
      );
    });
  });
}

/// Implements the interface without passing the verification token.
///
/// It implements every member, so the only thing wrong with it is the missing
/// token, which is what the interface is meant to catch.
class _BrokenPlatform implements MediaProviderAndroidPlatform {
  @override
  Future<List<MediaItem>> getMedia(QuerySpec query) async => [];

  @override
  Future<List<VolumeInfo>> getVolumes() async => [];
}
