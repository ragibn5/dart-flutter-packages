/// A media provider plugin for android.
library;

import 'package:media_provider_android/media_provider_android_platform_interface.dart';
import 'package:media_provider_android/src/media_item.dart';
import 'package:media_provider_android/src/media_type.dart';

export 'src/media_codec.dart';
export 'src/media_item.dart';
export 'src/media_type.dart';

class MediaProviderAndroid {
  /// Gets all media of [types] on the device.
  ///
  /// [types] must not be empty.
  Future<List<MediaItem>> getMedia(Set<MediaType> types) {
    return MediaProviderAndroidPlatform.instance.getMedia(types);
  }
}
