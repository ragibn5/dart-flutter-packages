import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:media_provider_android/src/media_codec.dart';
import 'package:media_provider_platform_interface/media_provider_platform_interface.dart';

class MediaProviderAndroid implements MediaProviderPlatform {
  static const CHANNEL_NAME = 'media_provider';
  static const GET_MEDIA_METHOD_NAME = 'getMedia';

  static const _channel = MethodChannel(CHANNEL_NAME);

  static void registerWith() {
    MediaProviderPlatform.instance = MediaProviderAndroid();
  }

  @override
  Future<List<MediaItem>> getMedia(Set<MediaType> types) async {
    assert(types.isNotEmpty, 'types must not be empty');

    final result = await _channel.invokeMethod<String>(GET_MEDIA_METHOD_NAME, {
      'types': types.map(encodeMediaType).toList(),
    });
    final items = jsonDecode(result!) as List<dynamic>;
    return items
        .map((item) => decodeMediaItem(item as Map<String, dynamic>))
        .toList();
  }
}
