import 'package:media_provider_android/media_provider_android_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class MediaProviderAndroidPlatform extends PlatformInterface {
  /// Constructs a MediaProviderAndroidPlatform.
  MediaProviderAndroidPlatform() : super(token: _token);

  static final Object _token = Object();

  static MediaProviderAndroidPlatform _instance =
      MethodChannelMediaProviderAndroid();

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

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
