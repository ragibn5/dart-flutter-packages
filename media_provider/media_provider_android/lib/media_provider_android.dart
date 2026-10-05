/// A media provider plugin for android.
library;

import 'package:media_provider_android/media_provider_android_platform_interface.dart';
import 'package:media_provider_android/src/android_media_item.dart';
import 'package:media_provider_android/src/android_media_type.dart';

export 'src/android_media_item.dart';
export 'src/android_media_type.dart';
export 'src/media_codec.dart';

class MediaProviderAndroid {
  /// Gets all media of [types] on the device.
  ///
  /// [types] must not be empty.
  Future<List<AndroidMediaItem>> getMedia(Set<AndroidMediaType> types) {
    return MediaProviderAndroidPlatform.instance.getMedia(types);
  }
}
