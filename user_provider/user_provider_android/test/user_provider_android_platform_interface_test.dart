import 'package:flutter_test/flutter_test.dart';
import 'package:user_provider_android/user_provider_android.dart';
import 'package:user_provider_android/user_provider_android_method_channel.dart';
import 'package:user_provider_android/user_provider_android_platform_interface.dart';

/// A platform implementation that extends the interface correctly, as the
/// `plugin_platform_interface` contract requires.
class _ExtendingPlatform extends UserProviderAndroidPlatform {}

void main() {
  late UserProviderAndroidPlatform initialInstance;

  setUp(() {
    initialInstance = UserProviderAndroidPlatform.instance;
  });

  tearDown(() {
    UserProviderAndroidPlatform.instance = initialInstance;
  });

  group('instance', () {
    test('defaults to the method channel implementation', () {
      expect(
        UserProviderAndroidPlatform.instance,
        isA<MethodChannelUserProviderAndroid>(),
      );
    });

    test('throws when set to an implementation that breaks the token', () {
      expect(
        () => UserProviderAndroidPlatform.instance = _BrokenPlatform(),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('getIdentity', () {
    test('throws UnimplementedError by default', () {
      final sut = _ExtendingPlatform();

      expect(
        sut.getIdentity,
        throwsA(
          // The message names the method that is missing, so a copy-paste
          // slip between the two members is caught here.
          isA<UnimplementedError>().having(
            (error) => error.message,
            'message',
            'getIdentity() has not been implemented.',
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
class _BrokenPlatform implements UserProviderAndroidPlatform {
  @override
  Future<UserIdentity> getIdentity() async =>
      const UserIdentity(uid: 0, userId: 0, appId: 0);
}
