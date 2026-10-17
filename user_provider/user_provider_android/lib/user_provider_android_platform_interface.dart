import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:user_provider_android/user_provider_android.dart';
import 'package:user_provider_android/user_provider_android_method_channel.dart';

abstract class UserProviderAndroidPlatform extends PlatformInterface {
  static final Object _token = Object();
  static UserProviderAndroidPlatform _instance =
      MethodChannelUserProviderAndroid();

  /// Constructs a UserProviderAndroidPlatform.
  UserProviderAndroidPlatform() : super(token: _token);

  /// The default instance of [UserProviderAndroidPlatform] to use.
  ///
  /// Defaults to [MethodChannelUserProviderAndroid].
  static UserProviderAndroidPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UserProviderAndroidPlatform] when
  /// they register themselves.
  static set instance(UserProviderAndroidPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Get the user identity.
  Future<UserIdentity> getIdentity() {
    throw UnimplementedError('getIdentity() has not been implemented.');
  }
}
