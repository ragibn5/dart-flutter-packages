import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/media_provider_android.dart';
import 'package:media_provider_android/media_provider_android_method_channel.dart';
import 'package:media_provider_android/media_provider_android_platform_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _MockMediaProviderAndroidPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements MediaProviderAndroidPlatform {}

const _photoItem = AndroidMediaItem(
  type: AndroidMediaType.photo,
  id: '1',
  uri: 'content://media/external/images/media/1',
  name: 'IMG_0001.jpg',
  mimeType: 'image/jpeg',
  sizeInBytes: 2048,
  dateAddedInMillis: 1700000000000,
  dateModifiedInMillis: 1700000001000,
  volumeName: 'external_primary',
  relativePath: 'DCIM/Camera/',
  isPending: false,
  isTrashed: false,
  isFavorite: false,
);

const _videoItem = AndroidMediaItem(
  type: AndroidMediaType.video,
  id: '2',
  uri: 'content://media/external/video/media/2',
  name: 'VID_0002.mp4',
  mimeType: 'video/mp4',
  sizeInBytes: 4096,
  dateAddedInMillis: 1700000002000,
  dateModifiedInMillis: 1700000003000,
  volumeName: null,
  relativePath: 'DCIM/Camera/',
  isPending: true,
  isTrashed: false,
  isFavorite: true,
);

void main() {
  late _MockMediaProviderAndroidPlatform first;

  late _MockMediaProviderAndroidPlatform second;

  late MediaProviderAndroid sut;

  setUpAll(() {
    registerFallbackValue(<AndroidMediaType>{});
  });

  setUp(() {
    first = _MockMediaProviderAndroidPlatform();
    second = _MockMediaProviderAndroidPlatform();
    when(
      () => first.getMedia(any()),
    ).thenAnswer((_) async => [_photoItem, _videoItem]);
    when(() => second.getMedia(any())).thenAnswer((_) async => [_photoItem]);

    sut = MediaProviderAndroid();
  });

  tearDown(() {
    MediaProviderAndroidPlatform.instance = MethodChannelMediaProviderAndroid();
  });

  group('getMedia', () {
    // The facade holds no state, so its only contract is that the call is
    // delegated to whichever instance is registered when it is made.
    test(
      'delegates to the instance set at call time, returning its result',
      () async {
        final types = <AndroidMediaType>{
          AndroidMediaType.photo,
          AndroidMediaType.video,
        };
        MediaProviderAndroidPlatform.instance = first;

        expect(await sut.getMedia(types), [_photoItem, _videoItem]);
        verify(() => first.getMedia(types)).called(1);

        // Re-registering must take effect, which it would not if the facade
        // had resolved the platform once at construction.
        MediaProviderAndroidPlatform.instance = second;

        expect(await sut.getMedia({AndroidMediaType.video}), [_photoItem]);
        verify(() => second.getMedia({AndroidMediaType.video})).called(1);
        verifyNoMoreInteractions(first);
      },
    );
  });
}
