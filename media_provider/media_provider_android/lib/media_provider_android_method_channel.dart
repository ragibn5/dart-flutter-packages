import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:media_provider_android/media_provider_android_platform_interface.dart';
import 'package:media_provider_android/src/models/media_item.dart';
import 'package:media_provider_android/src/models/query_spec.dart';
import 'package:media_provider_android/src/models/volume_info.dart';

// ignore: lines_longer_than_80_chars
/// An implementation of [MediaProviderAndroidPlatform] that uses method channels.
class MethodChannelMediaProviderAndroid extends MediaProviderAndroidPlatform {
  static const CHANNEL_NAME = 'media_provider_android';

  @visibleForTesting
  final methodChannel = const MethodChannel(CHANNEL_NAME);

  @override
  Future<List<VolumeInfo>> getVolumes() async {
    final result = await methodChannel.invokeMethod<String>('getVolumes');
    final items = jsonDecode(result!) as List<dynamic>;
    return items
        .map((item) => VolumeInfo.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MediaItem>> getMedia(QuerySpec query) async {
    final result = await methodChannel.invokeMethod<String>('getMedia', {
      'query': jsonEncode(query.toJson()),
    });
    final items = jsonDecode(result!) as List<dynamic>;
    return items
        .map((item) => MediaItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
