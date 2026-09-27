import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:media_provider_platform_interface/media_provider_platform_interface.dart';

class MediaProviderAndroid implements MediaProviderPlatform {
  static const CHANNEL_NAME = 'media_provider';
  static const GET_PHOTOS_METHOD_NAME = 'getPhotos';

  static const _channel = MethodChannel(CHANNEL_NAME);

  static void registerWith() {
    MediaProviderPlatform.instance = MediaProviderAndroid();
  }

  @override
  Future<List<MediaItem>> getPhotos() async {
    final result = await _channel.invokeMethod<String>(GET_PHOTOS_METHOD_NAME);
    final items = jsonDecode(result!) as List<dynamic>;
    return items
        .map((item) => MediaItem.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MediaItem>> getVideos() async {
    throw UnimplementedError();
  }
}
