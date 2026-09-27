/// Platform interface for media_provider package.
library;

import 'package:media_provider_platform_interface/media_provider_platform_interface.dart';

class MediaProvider {
  MediaProvider._();

  static final instance = MediaProvider._();

  Future<List<MediaItem>> getPhotos() {
    return MediaProviderPlatform.instance.getPhotos();
  }

  Future<List<MediaItem>> getVideos() {
    return MediaProviderPlatform.instance.getVideos();
  }
}
