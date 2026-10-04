/// Platform interface for media_provider package.
library;

import 'package:media_provider_platform_interface/src/media_item.dart';
import 'package:media_provider_platform_interface/src/media_type.dart';

export 'package:media_provider_platform_interface/src/media_item.dart';
export 'package:media_provider_platform_interface/src/media_type.dart';

abstract class MediaProviderPlatform {
  static MediaProviderPlatform instance = _UnimplementedMediaProvider();

  /// Gets all media of [types] on the device.
  ///
  /// NOTE: [types] must not be empty.
  Future<List<MediaItem>> getMedia(Set<MediaType> types);
}

class _UnimplementedMediaProvider implements MediaProviderPlatform {
  @override
  Future<List<MediaItem>> getMedia(Set<MediaType> types) {
    throw UnimplementedError('getMedia() has not been implemented.');
  }
}
