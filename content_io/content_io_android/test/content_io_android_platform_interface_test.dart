import 'package:content_io_android/content_io_android_method_channel.dart';
import 'package:content_io_android/content_io_android_platform_interface.dart';
import 'package:content_io_android/src/models/open_read_request.dart';
import 'package:content_io_android/src/models/open_thumbnail_read_request.dart';
import 'package:content_io_android/src/models/open_write_request.dart';
import 'package:content_io_android/src/models/thumbnail_size.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Extends the platform interface without overriding anything.
class _BarePlatform extends ContentIoAndroidPlatform {}

/// Implements the platform interface without its token.
class _TokenlessPlatform implements ContentIoAndroidPlatform {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Implements the platform interface the way test mocks do.
class _MockPlatform
    with MockPlatformInterfaceMixin
    implements ContentIoAndroidPlatform {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final platform = _BarePlatform();

  group('instance', () {
    late ContentIoAndroidPlatform original;

    setUp(() => original = ContentIoAndroidPlatform.instance);

    tearDown(() => ContentIoAndroidPlatform.instance = original);

    test('instanceShouldBeMethodChannelImplementationByDefault', () {
      expect(
        ContentIoAndroidPlatform.instance,
        isA<MethodChannelContentIoAndroid>(),
      );
    });

    test('instanceShouldBeReplacedIfSetToImplementationWithToken', () {
      final mock = _MockPlatform();

      ContentIoAndroidPlatform.instance = mock;

      expect(ContentIoAndroidPlatform.instance, same(mock));
    });

    test('instanceShouldThrowAssertionErrorIfSetWithoutToken', () {
      expect(
        () => ContentIoAndroidPlatform.instance = _TokenlessPlatform(),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  test('openReadSessionShouldThrowUnimplementedErrorIfNotOverridden', () {
    expect(
      () => platform.openReadSession(
        const OpenReadRequest(uri: 'content://media/1'),
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
            uri: 'content://media/1',
            size: ThumbnailSize(width: 256, height: 256),
          ),
        ),
        throwsUnimplementedError,
      );
    },
  );

  test('openWriteSessionShouldThrowUnimplementedErrorIfNotOverridden', () {
    expect(
      () => platform.openWriteSession(
        const OpenWriteRequest(uri: 'content://media/1'),
      ),
      throwsUnimplementedError,
    );
  });
}
