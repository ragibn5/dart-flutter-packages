import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_provider_android/user_provider_android.dart';
import 'package:user_provider_android/user_provider_android_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(MethodChannelUserProviderAndroid.CHANNEL_NAME);
  late MethodChannelUserProviderAndroid sut;

  setUp(() {
    sut = MethodChannelUserProviderAndroid();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  /// Installs a platform side that answers `getIdentity` with [response].
  void mockGetIdentity(Object? response) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => response);
  }

  group('getIdentity', () {
    test('uses its own channel', () {
      expect(sut.methodChannel.name, 'user_provider_android');
    });

    test('decodes the identity the platform replied with', () async {
      mockGetIdentity('{"uid":1010123,"userId":10,"appId":10123}');

      expect(
        await sut.getIdentity(),
        const UserIdentity(uid: 1010123, userId: 10, appId: 10123),
      );
    });

    test('invokes getIdentity with no arguments', () async {
      final calls = <MethodCall>[];

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return '{"uid":0,"userId":0,"appId":0}';
          });

      await sut.getIdentity();

      expect(calls, hasLength(1));
      expect(calls.single.method, 'getIdentity');
      expect(calls.single.arguments, isNull);
    });

    test('propagates the failure of the platform side', () async {
      mockGetIdentity(null);

      // A null reply is `notImplemented` on the wire, which is what a host with
      // no plugin registered sends. The decode must surface it rather than
      // reporting a malformed identity.
      expect(sut.getIdentity, throwsA(anything));
    });
  });
}
