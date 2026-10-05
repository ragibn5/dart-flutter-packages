import 'package:media_provider_android/media_provider_android_method_channel.dart';
import 'package:media_provider_android/src/media_item.dart';
import 'package:media_provider_android/src/media_type.dart';
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

  /// Gets all media of [types] on the device.
  ///
  /// NOTE: [types] must not be empty.
  Future<List<MediaItem>> getMedia(Set<MediaType> types) {
    throw UnimplementedError('getMedia() has not been implemented.');
  }
}
