import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_platform_interface/media_provider_platform_interface.dart';

void main() {
  test('is the default instance', () {
    expect(MediaProviderPlatform.instance, isA<MediaProviderPlatform>());
  });

  test('throws UnimplementedError on getMedia', () {
    final sut = MediaProviderPlatform.instance;

    expect(
      () => sut.getMedia({MediaType.photo}),
      throwsA(
        isA<UnimplementedError>().having(
          (error) => error.message,
          'message',
          'getMedia() has not been implemented.',
        ),
      ),
    );
  });
}
