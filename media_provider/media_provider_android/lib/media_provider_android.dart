import 'package:flutter/services.dart';
import 'package:media_provider_platform_interface/media_provider_platform_interface.dart';

class MediaProviderAndroid implements MediaProviderPlatform {
  static const CHANNEL_NAME = 'media_provider';
  static const _channel = MethodChannel(CHANNEL_NAME);

  static void registerWith() {
    MediaProviderPlatform.instance = MediaProviderAndroid();
  }

  @override
  Future<List<MediaItem>> getImages() async {
    final result = await _channel.invokeMethod<List<dynamic>>('getPhotos');
    return result!.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return MediaItem.fromMap(map);
    }).toList();
  }

  @override
  Future<List<MediaItem>> getVideos() async {
    throw UnimplementedError();
  }
}
