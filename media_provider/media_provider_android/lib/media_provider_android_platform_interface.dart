import 'package:media_provider_android/media_provider_android.dart';
import 'package:media_provider_android/media_provider_android_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class MediaProviderAndroidPlatform extends PlatformInterface {
  static final Object _token = Object();
  static MediaProviderAndroidPlatform _instance =
      MethodChannelMediaProviderAndroid();

  /// Constructs a MediaProviderAndroidPlatform.
  MediaProviderAndroidPlatform() : super(token: _token);

  /// The default instance of [MediaProviderAndroidPlatform] to use.
  ///
  /// Defaults to [MethodChannelMediaProviderAndroid].
  static MediaProviderAndroidPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MediaProviderAndroidPlatform] when
  /// they register themselves.
  static set instance(MediaProviderAndroidPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Queries `MediaStore` as per the given query.
  ///
  /// See the [AndroidMediaQuery] for more info.
  Future<List<AndroidMediaItem>> getMedia(AndroidMediaQuery query) {
    throw UnimplementedError('getMedia() has not been implemented.');
  }
}
