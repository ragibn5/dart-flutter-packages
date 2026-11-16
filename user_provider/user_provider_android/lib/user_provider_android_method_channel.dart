import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:user_provider_android/src/models/user_identity.dart';
import 'package:user_provider_android/user_provider_android_platform_interface.dart';

// ignore: lines_longer_than_80_chars
/// An implementation of [UserProviderAndroidPlatform] that uses method channels.
class MethodChannelUserProviderAndroid extends UserProviderAndroidPlatform {
  static const CHANNEL_NAME = 'user_provider_android';

  @visibleForTesting
  final methodChannel = const MethodChannel(CHANNEL_NAME);

  @override
  Future<UserIdentity> getIdentity() async {
    final result = await methodChannel.invokeMethod<String>('getIdentity');
    return UserIdentity.fromJson(jsonDecode(result!) as Map<String, dynamic>);
  }
}
