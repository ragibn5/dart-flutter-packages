/// Platform interface for media_provider package.
library;

import 'package:media_provider_platform_interface/media_provider_platform_interface.dart';

export 'package:media_provider_platform_interface/media_provider_platform_interface.dart'
    show MediaItem, MediaType;

class MediaProvider {
  MediaProvider._();

  static final instance = MediaProvider._();

  /// Gets all media of [types] on the device.
  ///
  /// [types] must not be empty.
  Future<List<MediaItem>> getMedia(Set<MediaType> types) {
    return MediaProviderPlatform.instance.getMedia(types);
  }
}
