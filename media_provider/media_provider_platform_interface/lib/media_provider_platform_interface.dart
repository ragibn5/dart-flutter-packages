/// Platform interface for media_provider package.
library;

import 'package:media_provider_platform_interface/src/media_item.dart';

export 'package:media_provider_platform_interface/src/media_item.dart';

abstract class MediaProviderPlatform {
  static MediaProviderPlatform instance = _UnimplementedMediaProvider();

  Future<List<MediaItem>> getPhotos();

  Future<List<MediaItem>> getVideos();
}

class _UnimplementedMediaProvider implements MediaProviderPlatform {
  @override
  Future<List<MediaItem>> getPhotos() {
    throw UnimplementedError('getPhotos() has not been implemented.');
  }

  @override
  Future<List<MediaItem>> getVideos() {
    throw UnimplementedError('getVideos() has not been implemented.');
  }
}
