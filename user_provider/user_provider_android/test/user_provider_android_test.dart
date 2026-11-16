import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:user_provider_android/user_provider_android.dart';
import 'package:user_provider_android/user_provider_android_method_channel.dart';
import 'package:user_provider_android/user_provider_android_platform_interface.dart';

class _MockUserProviderAndroidPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements UserProviderAndroidPlatform {}

const _identity = UserIdentity(uid: 1010123, userId: 10, appId: 10123);
const _otherIdentity = UserIdentity(uid: 0, userId: 0, appId: 0);

void main() {
  late _MockUserProviderAndroidPlatform first;

  late _MockUserProviderAndroidPlatform second;

  late UserProviderAndroid sut;

  setUp(() {
    first = _MockUserProviderAndroidPlatform();
    second = _MockUserProviderAndroidPlatform();
    when(first.getIdentity).thenAnswer((_) async => _identity);
    when(second.getIdentity).thenAnswer((_) async => _otherIdentity);

    sut = UserProviderAndroid();
  });

  tearDown(() {
    UserProviderAndroidPlatform.instance = MethodChannelUserProviderAndroid();
  });

  group('getIdentity', () {
    // The facade holds no state, so its only contract is that the call is
    // delegated to whichever instance is registered when it is made.
    test(
      'delegates to the instance set at call time, returning its result',
      () async {
        UserProviderAndroidPlatform.instance = first;

        expect(await sut.getIdentity(), _identity);
        verify(first.getIdentity).called(1);

        // Re-registering must take effect, which it would not if the facade
        // had resolved the platform once at construction.
        UserProviderAndroidPlatform.instance = second;

        expect(await sut.getIdentity(), _otherIdentity);
        verify(second.getIdentity).called(1);
        verifyNoMoreInteractions(first);
      },
    );
  });
}
