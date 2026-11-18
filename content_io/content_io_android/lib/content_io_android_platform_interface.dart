import 'package:content_io_android/content_io_android.dart';
import 'package:content_io_android/content_io_android_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class ContentIoAndroidPlatform extends PlatformInterface {
  static final Object _token = Object();
  static ContentIoAndroidPlatform _instance = MethodChannelContentIoAndroid();

  /// Constructs a ContentIoAndroidPlatform.
  ContentIoAndroidPlatform() : super(token: _token);

  /// The default instance of [ContentIoAndroidPlatform] to use.
  ///
  /// Defaults to [MethodChannelContentIoAndroid].
  static ContentIoAndroidPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ContentIoAndroidPlatform] when
  /// they register themselves.
  static set instance(ContentIoAndroidPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Opens a session for reading the content [request] points to.
  ///
  /// See [ContentReadSession] for more info.
  Future<ContentReadSession> openReadSession(OpenReadRequest request) {
    throw UnimplementedError('openReadSession() has not been implemented.');
  }

  /// Opens a session for reading the thumbnail of the content [request]
  /// points to.
  ///
  /// See [ContentReadSession] for more info.
  Future<ContentReadSession> openThumbnailReadSession(
    OpenThumbnailReadRequest request,
  ) {
    throw UnimplementedError(
      'openThumbnailReadSession() has not been implemented.',
    );
  }
}
