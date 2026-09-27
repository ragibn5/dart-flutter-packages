// import 'package:flutter_test/flutter_test.dart';
// import 'package:media_provider_android/media_provider_android.dart';
// import 'package:media_provider_android/media_provider_android_method_channel.dart';
// import 'package:media_provider_android/media_provider_android_platform_interface.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';
//
// class MockMediaProviderAndroidPlatform
//     with MockPlatformInterfaceMixin
//     implements MediaProviderAndroidPlatform {
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }
//
// void main() {
//   final initialPlatform = MediaProviderAndroidPlatform.instance;
//
//   test('$MethodChannelMediaProviderAndroid is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelMediaProviderAndroid>());
//   });
//
//   test('getPlatformVersion', () async {
//     final mediaProviderAndroidPlugin = MediaProviderAndroid();
//     final fakePlatform = MockMediaProviderAndroidPlatform();
//     MediaProviderAndroidPlatform.instance = fakePlatform;
//
//     expect(await mediaProviderAndroidPlugin.getPlatformVersion(), '42');
//   });
// }
