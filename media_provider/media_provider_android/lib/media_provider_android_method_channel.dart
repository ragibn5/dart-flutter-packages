import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:media_provider_android/media_provider_android_platform_interface.dart';
import 'package:media_provider_android/src/android_media_item.dart';
import 'package:media_provider_android/src/android_media_query.dart';

// ignore: lines_longer_than_80_chars
/// An implementation of [MediaProviderAndroidPlatform] that uses method channels.
class MethodChannelMediaProviderAndroid extends MediaProviderAndroidPlatform {
  static const CHANNEL_NAME = 'media_provider_android';

  @visibleForTesting
  final methodChannel = const MethodChannel(CHANNEL_NAME);

  @override
  Future<List<AndroidMediaItem>> getMedia(AndroidMediaQuery query) async {
    final result = await methodChannel.invokeMethod<String>('getMedia', {
      'query': jsonEncode(query.toJson()),
    });
    final items = jsonDecode(result!) as List<dynamic>;
    return items
        .map((item) => AndroidMediaItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
